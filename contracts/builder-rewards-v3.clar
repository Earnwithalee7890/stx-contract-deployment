;; title: Builder Rewards Contract V3 (Enhanced Fees)
;; version: 3.0.0
;; summary: A Clarity contract for Stacks Builder Challenge with 0.1 STX fees and rewards
;; description: Enhanced version with 0.1 STX check-in fee and 0.1 STX rewards.

;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-claimed (err u101))
(define-constant err-not-found (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-contract-inactive (err u104))
(define-constant err-insufficient-fee (err u105))

;; Fee constants (in microSTX)
(define-constant app-fee-check-in u100000)      ;; 0.1 STX per check-in
(define-constant app-fee-claim u100000)         ;; 0.1 STX per claim
(define-constant app-fee-score u100000)         ;; 0.1 STX per score submission
(define-constant reward-amount u100000)         ;; 0.1 STX reward

;; data vars
;;
(define-data-var total-rewards-distributed uint u0)
(define-data-var reward-pool uint u4000000) ;; 4 STX initial pool
(define-data-var contract-active bool true)

;; Fee tracking variables
(define-data-var total-fees-collected uint u0)
(define-data-var total-unique-users uint u0)
(define-data-var total-check-ins uint u0)
(define-data-var total-claims uint u0)

;; data maps
;;
(define-map user-claims principal bool)
(define-map user-scores principal uint)
(define-map daily-check-ins principal (list 365 uint))

;; User activity tracking
(define-map user-activity principal {
  first-interaction: uint,
  total-interactions: uint,
  total-fees-paid: uint
})

;; public functions
;;

;; Daily check-in with 0.1 STX fee
(define-public (daily-check-in)
  (let
    (
      (caller tx-sender)
      (current-day (/ stacks-block-height u144)) ;; Approx 1 day in blocks
      (existing-check-ins (default-to (list) (map-get? daily-check-ins caller)))
    )
    (asserts! (var-get contract-active) err-contract-inactive)
    
    ;; Collect 0.1 STX fee
    (try! (stx-transfer? app-fee-check-in caller (as-contract tx-sender)))
    
    ;; Track user and update stats
    (track-user caller app-fee-check-in)
    (var-set total-fees-collected (+ (var-get total-fees-collected) app-fee-check-in))
    (var-set total-check-ins (+ (var-get total-check-ins) u1))
    
    ;; Log event
    (print {
      event: "daily-check-in",
      user: caller,
      fee: app-fee-check-in,
      day: current-day,
      total-fees: (var-get total-fees-collected)
    })
    
    ;; Add current day to check-ins
    (ok (map-set daily-check-ins caller 
      (unwrap-panic (as-max-len? (append existing-check-ins current-day) u365))))
  )
)

;; Claim 0.1 STX reward with 0.1 STX fee
(define-public (claim-daily-reward)
  (let
    (
      (caller tx-sender)
      (current-height stacks-block-height)
      (has-claimed (default-to false (map-get? user-claims caller)))
    )
    (asserts! (var-get contract-active) err-contract-inactive)
    (asserts! (not has-claimed) err-already-claimed)
    (asserts! (>= (var-get reward-pool) reward-amount) err-invalid-amount)
    
    ;; Collect 0.1 STX fee
    (try! (stx-transfer? app-fee-claim caller (as-contract tx-sender)))
    
    ;; Transfer 0.1 STX reward
    (try! (as-contract (stx-transfer? reward-amount tx-sender caller)))
    
    ;; Track user and update stats
    (track-user caller app-fee-claim)
    (map-set user-claims caller true)
    (var-set total-fees-collected (+ (var-get total-fees-collected) app-fee-claim))
    (var-set total-claims (+ (var-get total-claims) u1))
    (var-set total-rewards-distributed (+ (var-get total-rewards-distributed) reward-amount))
    (var-set reward-pool (- (var-get reward-pool) reward-amount))
    
    ;; Log event
    (print {
      event: "claim-reward",
      user: caller,
      reward: reward-amount,
      fee: app-fee-claim,
      total-fees: (var-get total-fees-collected)
    })
    
    (ok reward-amount)
  )
)

;; Record user score with 0.1 STX fee
(define-public (record-score (score uint))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (> score u0) err-invalid-amount)
    (asserts! (var-get contract-active) err-contract-inactive)
    
    ;; Collect 0.1 STX fee
    (try! (stx-transfer? app-fee-score caller (as-contract tx-sender)))
    
    ;; Track user and update stats
    (track-user caller app-fee-score)
    (map-set user-scores caller score)
    (var-set total-fees-collected (+ (var-get total-fees-collected) app-fee-score))
    
    ;; Log event
    (print {
      event: "record-score",
      user: caller,
      score: score,
      fee: app-fee-score,
      total-fees: (var-get total-fees-collected)
    })
    
    (ok true)
  )
)

;; Owner function to add to reward pool
(define-public (fund-rewards (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    
    (print {event: "fund-rewards", amount: amount, new-pool: (var-get reward-pool)})
    (ok true)
  )
)

;; Owner function to withdraw collected fees
(define-public (withdraw-fees)
  (let
    (
      (fee-amount (var-get total-fees-collected))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> fee-amount u0) err-invalid-amount)
    
    ;; Transfer fees to owner
    (try! (as-contract (stx-transfer? fee-amount tx-sender contract-owner)))
    
    ;; Reset fee counter
    (var-set total-fees-collected u0)
    
    (print {event: "withdraw-fees", amount: fee-amount, recipient: contract-owner})
    (ok fee-amount)
  )
)

;; Toggle contract active status
(define-public (toggle-contract-status)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-active (not (var-get contract-active)))
    (ok (var-get contract-active))
  )
)

;; read only functions
;;

;; Get total fees collected
(define-read-only (get-total-fees-collected)
  (ok (var-get total-fees-collected))
)

;; Get unique user count
(define-read-only (get-unique-user-count)
  (ok (var-get total-unique-users))
)

;; Get comprehensive fee summary
(define-read-only (get-fee-summary)
  (ok {
    total-fees-collected: (var-get total-fees-collected),
    total-unique-users: (var-get total-unique-users),
    total-check-ins: (var-get total-check-ins),
    total-claims: (var-get total-claims),
    total-rewards-distributed: (var-get total-rewards-distributed),
    current-reward-pool: (var-get reward-pool),
    contract-active: (var-get contract-active),
    check-in-fee: app-fee-check-in,
    claim-fee: app-fee-claim,
    reward-amount: reward-amount
  })
)

;; Get user activity details
(define-read-only (get-user-activity (user principal))
  (ok (map-get? user-activity user))
)

;; Get user score
(define-read-only (get-user-score (user principal))
  (ok (default-to u0 (map-get? user-scores user)))
)

;; Get total rewards distributed
(define-read-only (get-total-rewards)
  (ok (var-get total-rewards-distributed))
)

;; Get reward pool balance
(define-read-only (get-reward-pool)
  (ok (var-get reward-pool))
)

;; Check if user has claimed
(define-read-only (has-user-claimed (user principal))
  (ok (default-to false (map-get? user-claims user)))
)

;; Get user check-in count
(define-read-only (get-check-in-count (user principal))
  (ok (len (default-to (list) (map-get? daily-check-ins user))))
)

;; Get contract status
(define-read-only (is-contract-active)
  (ok (var-get contract-active))
)

;; Get user display info
(define-read-only (get-user-display-info (user principal))
  (ok {
    user: user,
    score: (default-to u0 (map-get? user-scores user)),
    claimed: (default-to false (map-get? user-claims user)),
    check-ins: (len (default-to (list) (map-get? daily-check-ins user))),
    activity: (map-get? user-activity user)
  })
)

;; Get fee rates
(define-read-only (get-fee-rates)
  (ok {
    check-in-fee: app-fee-check-in,
    claim-fee: app-fee-claim,
    score-fee: app-fee-score,
    reward-amount: reward-amount
  })
)

;; private functions
;;

;; Track user activity and fees
(define-private (track-user (user principal) (fee-paid uint))
  (match (map-get? user-activity user)
    ;; Existing user - update stats
    activity (map-set user-activity user {
      first-interaction: (get first-interaction activity),
      total-interactions: (+ (get total-interactions activity) u1),
      total-fees-paid: (+ (get total-fees-paid activity) fee-paid)
    })
    ;; New user - create record and increment unique user count
    (begin
      (map-set user-activity user {
        first-interaction: stacks-block-height,
        total-interactions: u1,
        total-fees-paid: fee-paid
      })
      (var-set total-unique-users (+ (var-get total-unique-users) u1))
    )
  )
)
