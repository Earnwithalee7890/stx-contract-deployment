;; Simple Poll System
(define-map votes {poll-id: uint, voter: principal} bool)
(define-map poll-counts uint uint)

(define-public (cast-vote (poll-id uint))
  (begin
    (map-set votes {poll-id: poll-id, voter: tx-sender} true)
    (map-set poll-counts poll-id (+ u1 (default-to u0 (map-get? poll-counts poll-id))))
    (ok true)
  )
)

(define-read-only (get-votes (poll-id uint))
  (default-to u0 (map-get? poll-counts poll-id))
)
