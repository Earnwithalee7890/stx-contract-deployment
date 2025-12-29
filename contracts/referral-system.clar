;; title: Referral System
;; version: 1.0.0
;; summary: Manage user referrals and rewards

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-referred (err u101))
(define-constant err-no-referrer (err u102))
(define-constant err-invalid-user (err u103))

;; Referral reward in microSTX (e.g., 0.05 STX)
(define-constant referral-reward u50000)

;; Data Maps
(define-map referrers principal principal) ;; referred -> referrer
(define-map referral-counts principal uint) ;; referrer -> count
(define-map referral-earnings principal uint) ;; referrer -> total-earned

;; Public Functions

;; Register a user with a referrer
(define-public (register-with-referrer (referrer principal))
    (let
        ((caller tx-sender))
        (asserts! (not (is-eq caller referrer)) err-invalid-user)
        (asserts! (is-none (map-get? referrers caller)) err-already-referred)
        
        ;; Set the referrer
        (map-set referrers caller referrer)
        
        ;; Update referral count for the referrer
        (let
            ((current-count (default-to u0 (map-get? referral-counts referrer))))
            (map-set referral-counts referrer (+ current-count u1))
        )
        
        (ok true)
    )
)

;; Reward a referrer (usually called by another contract like builder-rewards)
(define-public (reward-referrer (user principal))
    (let
        ((referrer (unwrap! (map-get? referrers user) err-no-referrer)))
        ;; This would typically involve a transfer from a reward pool
        ;; For now, we update the earnings record
        (let
            ((current-earnings (default-to u0 (map-get? referral-earnings referrer))))
            (map-set referral-earnings referrer (+ current-earnings referral-reward))
            (ok referral-reward)
        )
    )
)

;; Read-only functions

(define-read-only (get-referrer (user principal))
    (ok (map-get? referrers user))
)

(define-read-only (get-referral-stats (user principal))
    (ok {
        referrals: (default-to u0 (map-get? referral-counts user)),
        earnings: (default-to u0 (map-get? referral-earnings user))
    })
)
