;; Access Control System
(define-map permissions principal bool)
(define-data-var admin principal tx-sender)

(define-public (grant-access (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (map-set permissions user true))
  )
)

(define-read-only (has-access (user principal))
  (default-to false (map-get? permissions user))
)
