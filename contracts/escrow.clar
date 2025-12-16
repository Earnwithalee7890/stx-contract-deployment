;; Escrow Contract
;; Hold funds in escrow

(define-constant err-not-authorized (err u100))
(define-constant err-escrow-not-found (err u101))
(define-constant err-owner-only (err u200))

;; Fee constant - 0.1% = 100 basis points
(define-constant escrow-fee-bps u100)

;; Fee tracking
(define-data-var total-fees-collected uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map escrows uint {
  sender: principal,
  recipient: principal,
  amount: uint,
  released: bool
})
(define-data-var escrow-nonce uint u0)

(define-public (create-escrow (recipient principal) (amount uint))
  (let 
    (
      (id (+ (var-get escrow-nonce) u1))
      (fee (/ (* amount escrow-fee-bps) u100000)) ;; Calculate 0.1% fee
      (total-amount (+ amount fee))
    )
    ;; Transfer amount + fee to contract
    (try! (stx-transfer? total-amount tx-sender (as-contract tx-sender)))
    
    ;; Track fee
    (var-set total-fees-collected (+ (var-get total-fees-collected) fee))
    
    (map-set escrows id {
      sender: tx-sender,
      recipient: recipient,
      amount: amount,
      released: false
    })
    (var-set escrow-nonce id)
    
    ;; Log event
    (print {event: "escrow-fee", sender: tx-sender, escrow-amount: amount, fee: fee})
    (ok id)
  )
)

(define-public (release-escrow (escrow-id uint))
  (match (map-get? escrows escrow-id)
    escrow (begin
      (asserts! (is-eq tx-sender (get sender escrow)) err-not-authorized)
      (asserts! (not (get released escrow)) err-not-authorized)
      (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get recipient escrow))))
      (map-set escrows escrow-id (merge escrow {released: true}))
      (ok true)
    )
    err-escrow-not-found
  )
)

(define-read-only (get-escrow (id uint))
  (ok (map-get? escrows id))
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
