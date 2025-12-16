;; Timelock Contract
;; Lock STX until a specific block height

(define-constant err-too-early (err u100))
(define-constant err-not-found (err u101))
(define-constant err-owner-only (err u200))

;; Fee constant
(define-constant lock-creation-fee u8) ;; 8 microSTX

;; Fee tracking
(define-data-var total-fees-collected uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map locks uint {
  owner: principal,
  amount: uint,
  unlock-height: uint,
  unlocked: bool
})
(define-data-var lock-nonce uint u0)

(define-public (create-lock (amount uint) (unlock-height uint))
  (let ((id (+ (var-get lock-nonce) u1)))
    ;; Collect fee
    (try! (stx-transfer? lock-creation-fee tx-sender (as-contract tx-sender)))
    (var-set total-fees-collected (+ (var-get total-fees-collected) lock-creation-fee))
    
    ;; Transfer lock amount
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (map-set locks id {
      owner: tx-sender,
      amount: amount,
      unlock-height: unlock-height,
      unlocked: false
    })
    (var-set lock-nonce id)
    
    ;; Log event
    (print {event: "lock-fee", owner: tx-sender, amount: amount, fee: lock-creation-fee})
    (ok id)
  )
)

(define-public (unlock (lock-id uint))
  (match (map-get? locks lock-id)
    lock-data (begin
      (asserts! (>= stacks-block-height (get unlock-height lock-data)) err-too-early)
      (asserts! (is-eq tx-sender (get owner lock-data)) err-not-found)
      (try! (as-contract (stx-transfer? (get amount lock-data) tx-sender (get owner lock-data))))
      (map-set locks lock-id (merge lock-data {unlocked: true}))
      (ok true)
    )
    err-not-found
  )
)

(define-read-only (get-lock (id uint))
  (ok (map-get? locks id))
)

;; Get total fees collected
(define-read-only (get-total-fees)
  (ok (var-get total-fees-collected))
)

;; Withdraw fees (owner only)
(define-public (withdraw-fees)
  (let ((amount (var-get total-fees-collected)))
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (asserts! (> amount u0) (err u201))
    (try! (as-contract (stx-transfer? amount tx-sender (var-get contract-owner))))
    (var-set total-fees-collected u0)
    (ok amount)
  )
)
