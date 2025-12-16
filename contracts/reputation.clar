;; Reputation System Contract
;; Track user reputation scores

;; Fee constant
(define-constant endorsement-fee u5) ;; 5 microSTX to prevent spam
(define-constant err-owner-only (err u200))

;; Fee tracking
(define-data-var total-fees-collected uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map reputation principal {score: uint, endorsements: uint})
(define-map endorsers {user: principal, endorser: principal} bool)

(define-public (endorse (user principal))
  (let ((endorser tx-sender))
    (asserts! (not (is-eq user endorser)) (err u100))
    (asserts! (is-none (map-get? endorsers {user: user, endorser: endorser})) (err u101))
    
    ;; Collect fee
    (try! (stx-transfer? endorsement-fee endorser (as-contract tx-sender)))
    (var-set total-fees-collected (+ (var-get total-fees-collected) endorsement-fee))
    
    (map-set endorsers {user: user, endorser: endorser} true)
    (match (map-get? reputation user)
      rep (map-set reputation user {
        score: (+ (get score rep) u10),
        endorsements: (+ (get endorsements rep) u1)
      })
      (map-set reputation user {score: u10, endorsements: u1})
    )
    
    ;; Log event
    (print {event: "endorsement-fee", endorser: endorser, endorsed: user, fee: endorsement-fee})
    (ok true)
  )
)

(define-public (add-reputation (user principal) (points uint))
  (begin
    (match (map-get? reputation user)
      rep (map-set reputation user (merge rep {score: (+ (get score rep) points)}))
      (map-set reputation user {score: points, endorsements: u0})
    )
    (ok true)
  )
)

(define-read-only (get-reputation (user principal))
  (ok (map-get? reputation user))
)

(define-read-only (has-endorsed (user principal) (endorser principal))
  (ok (default-to false (map-get? endorsers {user: user, endorser: endorser})))
)

;; Get total fees collected
(define-read-only (get-total-fees)
  (ok (var-get total-fees-collected))
)

;; Withdraw collected fees (owner only)
(define-public (withdraw-fees)
  (let ((amount (var-get total-fees-collected)))
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (asserts! (> amount u0) (err u201))
    (try! (as-contract (stx-transfer? amount tx-sender (var-get contract-owner))))
    (var-set total-fees-collected u0)
    (ok amount)
  )
)
