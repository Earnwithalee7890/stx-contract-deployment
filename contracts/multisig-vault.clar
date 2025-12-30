
;; multisig-vault.clar
;; N-of-M Multisig Vault
;; Clarity 4

(define-constant err-owner-only (err u500))
(define-constant err-already-confirmed (err u501))
(define-constant err-tx-not-found (err u502))
(define-constant err-tx-already-executed (err u503))

(define-data-var owners (list 20 principal) (list))
(define-data-var required-confirmations uint u1)
(define-data-var tx-count uint u0)

(define-map transactions 
    uint 
    {
        destination: principal,
        amount: uint,
        confirmations: uint,
        executed: bool
    }
)

(define-map confirmations { tx-id: uint, owner: principal } bool)

(define-read-only (is-owner (user principal))
    (is-some (index-of (var-get owners) user))
)

;; Init with owners and required-confirmations
(define-public (init (new-owners (list 20 principal)) (required uint))
    (begin
        (asserts! (is-eq (var-get tx-count) u0) (err u504)) ;; Only allow if fresh
        (var-set owners new-owners)
        (var-set required-confirmations required)
        (ok true)
    )
)

(define-public (submit-transaction (destination principal) (amount uint))
    (let
        (
            (tx-id (+ (var-get tx-count) u1))
        )
        (asserts! (is-owner tx-sender) err-owner-only)
        (map-set transactions tx-id {
            destination: destination,
            amount: amount,
            confirmations: u0,
            executed: false
        })
        (var-set tx-count tx-id)
        (confirm-transaction tx-id) ;; Auto-confirm by submitter
    )
)

(define-public (confirm-transaction (tx-id uint))
    (let
        (
            (tx (unwrap! (map-get? transactions tx-id) err-tx-not-found))
        )
        (asserts! (is-owner tx-sender) err-owner-only)
        (asserts! (not (get executed tx)) err-tx-already-executed)
        (asserts! (is-none (map-get? confirmations { tx-id: tx-id, owner: tx-sender })) err-already-confirmed)
        
        (map-set confirmations { tx-id: tx-id, owner: tx-sender } true)
        (map-set transactions tx-id (merge tx { confirmations: (+ (get confirmations tx) u1) }))
        
        (ok true)
    )
)

(define-public (execute-transaction (tx-id uint))
    (let
        (
            (tx (unwrap! (map-get? transactions tx-id) err-tx-not-found))
        )
        (asserts! (not (get executed tx)) err-tx-already-executed)
        (asserts! (>= (get confirmations tx) (var-get required-confirmations)) (err u505))
        
        (try! (as-contract (stx-transfer? (get amount tx) tx-sender (get destination tx))))
        (map-set transactions tx-id (merge tx { executed: true }))
        (ok true)
    )
)
