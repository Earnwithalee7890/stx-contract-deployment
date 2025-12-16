;; STX Vault Contract
;; A simple vault for storing and managing STX

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))

;; Fee constant - 0.05% = 50 basis points
(define-constant withdrawal-fee-bps u50)

;; Fee tracking
(define-data-var total-fees-collected uint u0)

(define-data-var total-deposits uint u0)

(define-map user-balances principal uint)

(define-public (deposit (amount uint))
  (let ((sender tx-sender))
    (try! (stx-transfer? amount sender (as-contract tx-sender)))
    (map-set user-balances sender (+ (get-balance sender) amount))
    (var-set total-deposits (+ (var-get total-deposits) amount))
    (ok amount)
  )
)

(define-public (withdraw (amount uint))
  (let 
    (
      (sender tx-sender)
      (balance (get-balance sender))
      (withdrawal-fee (/ (* amount withdrawal-fee-bps) u100000)) ;; Calculate 0.05% fee
      (net-amount (- amount withdrawal-fee))
    )
    (asserts! (>= balance amount) err-insufficient-balance)
    
    ;; Transfer net amount (minus fee) to user
    (try! (as-contract (stx-transfer? net-amount tx-sender sender)))
    
    ;; Track fee (stays in contract)
    (var-set total-fees-collected (+ (var-get total-fees-collected) withdrawal-fee))
    
    ;; Update user balance
    (map-set user-balances sender (- balance amount))
    
    ;; Log event
    (print {event: "withdrawal-fee", user: sender, amount: amount, fee: withdrawal-fee, net: net-amount})
    (ok net-amount)
  )
)

(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? user-balances user))
)

(define-read-only (get-total-deposits)
  (ok (var-get total-deposits))
)

;; Get total fees collected
(define-read-only (get-total-fees)
  (ok (var-get total-fees-collected))
)

;; Withdraw fees (owner only)
(define-public (withdraw-fees)
  (let ((amount (var-get total-fees-collected)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) (err u201))
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (var-set total-fees-collected u0)
    (ok amount)
  )
)
