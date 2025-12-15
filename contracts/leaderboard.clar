;; Leaderboard System
(define-map scores principal uint)

(define-public (update-score (points uint))
  (ok (map-set scores tx-sender points))
)

(define-read-only (get-score (player principal))
  (default-to u0 (map-get? scores player))
)
