;; Achievement Tracker
(define-map achievements {user: principal, achievement-id: uint} bool)

(define-public (unlock-achievement (id uint))
  (ok (map-set achievements {user: tx-sender, achievement-id: id} true))
)

(define-read-only (has-achievement (user principal) (id uint))
  (default-to false (map-get? achievements {user: user, achievement-id: id}))
)
