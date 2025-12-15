;; Referral Tracking System
(define-map referrals principal uint)

(define-public (add-referral)
  (ok (map-set referrals tx-sender (+ u1 (default-to u0 (map-get? referrals tx-sender)))))
)

(define-read-only (get-referral-count (user principal))
  (default-to u0 (map-get? referrals user))
)
