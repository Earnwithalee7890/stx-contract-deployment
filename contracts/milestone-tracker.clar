;; Milestone Tracker
(define-map milestones {user: principal, milestone-id: uint} uint)

(define-public (update-progress (milestone-id uint) (progress uint))
  (ok (map-set milestones {user: tx-sender, milestone-id: milestone-id} progress))
)

(define-read-only (get-progress (user principal) (milestone-id uint))
  (default-to u0 (map-get? milestones {user: user, milestone-id: milestone-id}))
)
