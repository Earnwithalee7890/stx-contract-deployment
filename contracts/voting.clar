;; Voting Contract
;; Create and vote on proposals

(define-constant err-already-voted (err u100))
(define-constant err-owner-only (err u200))

;; Fee constants
(define-constant proposal-creation-fee u10) ;; 10 microSTX

;; Fee tracking
(define-data-var total-fees-collected uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map proposals uint {title: (string-ascii 64), votes-for: uint, votes-against: uint})
(define-map has-voted {proposal-id: uint, voter: principal} bool)
(define-data-var proposal-count uint u0)

(define-public (create-proposal (title (string-ascii 64)))
  (let ((id (var-get proposal-count)))
    ;; Collect fee
    (try! (stx-transfer? proposal-creation-fee tx-sender (as-contract tx-sender)))
    (var-set total-fees-collected (+ (var-get total-fees-collected) proposal-creation-fee))
    
    (map-set proposals id {title: title, votes-for: u0, votes-against: u0})
    (var-set proposal-count (+ id u1))
    
    ;; Log event
    (print {event: "proposal-fee", creator: tx-sender, proposal-id: id, fee: proposal-creation-fee})
    (ok id)
  )
)

(define-public (vote (proposal-id uint) (vote-for bool))
  (let ((voter tx-sender))
    (asserts! (is-none (map-get? has-voted {proposal-id: proposal-id, voter: voter})) err-already-voted)
    (map-set has-voted {proposal-id: proposal-id, voter: voter} true)
    (match (map-get? proposals proposal-id)
      proposal (if vote-for
        (map-set proposals proposal-id (merge proposal {votes-for: (+ (get votes-for proposal) u1)}))
        (map-set proposals proposal-id (merge proposal {votes-against: (+ (get votes-against proposal) u1)}))
      )
      false
    )
    (ok true)
  )
)

(define-read-only (get-proposal (id uint))
  (ok (map-get? proposals id))
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
