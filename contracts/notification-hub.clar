;; Notification Hub
(define-map notifications principal uint)

(define-public (increment-notifications)
  (ok (map-set notifications tx-sender (+ u1 (default-to u0 (map-get? notifications tx-sender)))))
)

(define-read-only (get-notification-count (user principal))
  (default-to u0 (map-get? notifications user))
)
