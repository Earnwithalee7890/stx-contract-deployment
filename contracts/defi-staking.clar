
;; defi-staking.clar
;; A staking contract where users stake STX to earn a simulated yield token.
;; Clarity 4

(define-constant err-amount-zero (err u200))
(define-constant err-insufficient-stake (err u201))

(define-map stakes 
    principal 
    {
        amount: uint,
        last-claimed-block: uint
    }
)

(define-data-var reward-rate-per-block uint u10) ;; 10 micro-rewards per block per STX

;; Mock reward token logic - in production satisfy SIP-010
;; For this example, we just track "points"
(define-map rewards-balance principal uint)

(define-read-only (get-rewards-balance (user principal))
    (default-to u0 (map-get? rewards-balance user))
)

(define-read-only (calculate-rewards (user principal))
    (let
        (
            (stake-info (default-to { amount: u0, last-claimed-block: burn-block-height } (map-get? stakes user)))
            (blocks-passed (- burn-block-height (get last-claimed-block stake-info)))
        )
        (* (get amount stake-info) blocks-passed (var-get reward-rate-per-block))
    )
)

(define-public (stake (amount uint))
    (let
        (
            (current-stake (default-to { amount: u0, last-claimed-block: burn-block-height } (map-get? stakes tx-sender)))
            (pending-rewards (calculate-rewards tx-sender))
            (current-rewards (get-rewards-balance tx-sender))
        )
        (asserts! (> amount u0) err-amount-zero)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Update rewards balance
        (map-set rewards-balance tx-sender (+ current-rewards pending-rewards))
        
        ;; Update stake info
        (map-set stakes tx-sender {
            amount: (+ (get amount current-stake) amount),
            last-claimed-block: burn-block-height
        })
        (ok true)
    )
)

(define-public (unstake (amount uint))
    (let
        (
            (current-stake (default-to { amount: u0, last-claimed-block: burn-block-height } (map-get? stakes tx-sender)))
            (pending-rewards (calculate-rewards tx-sender))
            (current-rewards (get-rewards-balance tx-sender))
        )
        (asserts! (>= (get amount current-stake) amount) err-insufficient-stake)
        
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        
        ;; Update rewards balance
        (map-set rewards-balance tx-sender (+ current-rewards pending-rewards))
        
        ;; Update stake info
        (map-set stakes tx-sender {
            amount: (- (get amount current-stake) amount),
            last-claimed-block: burn-block-height
        })
        (ok true)
    )
)

(define-public (claim-rewards)
    (let
        (
            (pending (calculate-rewards tx-sender))
            (current-rewards (get-rewards-balance tx-sender))
            (stake-info (unwrap! (map-get? stakes tx-sender) err-insufficient-stake))
        )
        ;; In a real app, this would mint a SIP-010 token
        ;; Here we just update the internal ledger as "claimed" (moved to balance) if we had a separate "claimed" map,
        ;; but our model purely tracks balance in `rewards-balance`.
        ;; So this function essentially checkpoints the calculation.
        
        (map-set rewards-balance tx-sender (+ current-rewards pending))
        (map-set stakes tx-sender (merge stake-info { last-claimed-block: burn-block-height }))
        (ok pending)
    )
)
