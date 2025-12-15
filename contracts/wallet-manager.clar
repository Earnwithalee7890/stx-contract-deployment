;; Wallet Manager - Track user balances
(define-map wallets principal uint)

(define-public (add-funds (amount uint))
  (ok (map-set wallets tx-sender (+ (default-to u0 (map-get? wallets tx-sender)) amount)))
)

(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? wallets user))
)
