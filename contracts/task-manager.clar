;; Task Manager
(define-map tasks {owner: principal, task-id: uint} {completed: bool})

(define-public (complete-task (id uint))
  (ok (map-set tasks {owner: tx-sender, task-id: id} {completed: true}))
)

(define-read-only (is-completed (owner principal) (id uint))
  (get completed (default-to {completed: false} (map-get? tasks {owner: owner, task-id: id})))
)
