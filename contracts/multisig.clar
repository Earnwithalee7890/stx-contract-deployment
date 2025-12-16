;; Multisig Wallet Contract
;; Simple multisig wallet requiring 2 of 3 approvals

;; Fee constants
(define-constant proposal-fee u10) ;; 10 microSTX

;; Fee tracking
(define-data-var total-fees-collected uint u0)

(define-constant owner-1 tx-sender)
(define-data-var owner-2 principal tx-sender)
(define-data-var owner-3 principal tx-sender)

(define-map pending-transactions uint {
  to: principal,
  amount: uint,
  approvals: uint,
  executed: bool
})
(define-map has-approved {tx-id: uint, owner: principal} bool)
(define-data-var tx-nonce uint u0)

(define-public (propose-transaction (to principal) (amount uint))
  (let ((tx-id (+ (var-get tx-nonce) u1)))
    ;; Collect fee
    (try! (stx-transfer? proposal-fee tx-sender (as-contract tx-sender)))
    (var-set total-fees-collected (+ (var-get total-fees-collected) proposal-fee))
    
    (map-set pending-transactions tx-id {
      to: to,
      amount: amount,
      approvals: u1,
      executed: false
    })
    (map-set has-approved {tx-id: tx-id, owner: tx-sender} true)
    (var-set tx-nonce tx-id)
    
    ;; Log event
    (print {event: "proposal-fee", proposer: tx-sender, tx-id: tx-id, fee: proposal-fee})
    (ok tx-id)
  )
)

(define-public (approve-transaction (tx-id uint))
  (match (map-get? pending-transactions tx-id)
    tx-data (begin
      (asserts! (is-none (map-get? has-approved {tx-id: tx-id, owner: tx-sender})) (err u100))
      (map-set has-approved {tx-id: tx-id, owner: tx-sender} true)
      (let ((new-approvals (+ (get approvals tx-data) u1)))
        (map-set pending-transactions tx-id (merge tx-data {approvals: new-approvals}))
        (if (>= new-approvals u2)
          (execute-transaction tx-id)
          (ok true)
        )
      )
    )
    (err u101)
  )
)

(define-private (execute-transaction (tx-id uint))
  (match (map-get? pending-transactions tx-id)
    tx-data (begin
      (try! (as-contract (stx-transfer? (get amount tx-data) tx-sender (get to tx-data))))
      (map-set pending-transactions tx-id (merge tx-data {executed: true}))
      (ok true)
    )
    (err u102)
  )
)

(define-read-only (get-transaction (tx-id uint))
  (ok (map-get? pending-transactions tx-id))
)

;; Get total fees collected
(define-read-only (get-total-fees)
  (ok (var-get total-fees-collected))
)

;; Withdraw fees (any owner can call)
(define-public (withdraw-fees)
  (let ((amount (var-get total-fees-collected)))
    (asserts! (> amount u0) (err u300))
    ;; Check if caller is one of the owners
    (asserts! (or (is-eq tx-sender owner-1)
                  (or (is-eq tx-sender (var-get owner-2))
                      (is-eq tx-sender (var-get owner-3)))) (err u301))
    (try! (as-contract (stx-transfer? amount tx-sender owner-1)))
    (var-set total-fees-collected u0)
    (ok amount)
  )
)
