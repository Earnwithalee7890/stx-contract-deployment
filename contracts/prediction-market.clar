
;; prediction-market.clar
;; Binary prediction market resolved by an admin/oracle.
;; Clarity 4

(define-constant err-market-closed (err u900))
(define-constant err-market-not-resolved (err u901))
(define-constant err-only-oracle (err u902))
(define-constant err-nothing-to-claim (err u903))

(define-data-var oracle principal tx-sender)

(define-map markets 
    uint 
    {
        question: (string-utf8 100),
        end-block: uint,
        resolved: bool,
        outcome: bool, ;; true = YES, false = NO
        total-yes: uint,
        total-no: uint
    }
)

(define-map bets { market-id: uint, user: principal, side: bool } uint)

(define-data-var market-nonce uint u0)

(define-public (create-market (question (string-utf8 100)) (duration uint))
    (let
        (
            (id (+ (var-get market-nonce) u1))
        )
        (asserts! (is-eq tx-sender (var-get oracle)) err-only-oracle)
        (map-set markets id {
            question: question,
            end-block: (+ burn-block-height duration),
            resolved: false,
            outcome: false,
            total-yes: u0,
            total-no: u0
        })
        (var-set market-nonce id)
        (ok id)
    )
)

(define-public (bet (market-id uint) (amount uint) (side bool))
    (let
        (
            (market (unwrap! (map-get? markets market-id) (err u904)))
            (current-bet (default-to u0 (map-get? bets { market-id: market-id, user: tx-sender, side: side })))
        )
        (asserts! (< burn-block-height (get end-block market)) err-market-closed)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        (map-set bets { market-id: market-id, user: tx-sender, side: side } (+ current-bet amount))
        
        (if side
            (map-set markets market-id (merge market { total-yes: (+ (get total-yes market) amount) }))
            (map-set markets market-id (merge market { total-no: (+ (get total-no market) amount) }))
        )
        (ok true)
    )
)

(define-public (resolve-market (market-id uint) (outcome bool))
    (let
        (
            (market (unwrap! (map-get? markets market-id) (err u904)))
        )
        (asserts! (is-eq tx-sender (var-get oracle)) err-only-oracle)
        (asserts! (not (get resolved market)) err-market-closed)
        
        (map-set markets market-id (merge market { resolved: true, outcome: outcome }))
        (ok true)
    )
)

(define-public (claim-winnings (market-id uint))
    (let
        (
            (market (unwrap! (map-get? markets market-id) (err u904)))
            (user-bet (default-to u0 (map-get? bets { market-id: market-id, user: tx-sender, side: (get outcome market) })))
            (total-winning-pool (if (get outcome market) (get total-yes market) (get total-no market)))
            (total-losing-pool (if (get outcome market) (get total-no market) (get total-yes market)))
            (total-pool (+ total-winning-pool total-losing-pool))
        )
        (asserts! (get resolved market) err-market-not-resolved)
        (asserts! (> user-bet u0) err-nothing-to-claim)
        
        ;; Payout = UserBet + (UserBet / TotalWinningPool) * TotalLosingPool
        ;; Simplified: (UserBet * TotalPool) / TotalWinningPool
        
        (let
            (
                (payout (/ (* user-bet total-pool) total-winning-pool))
            )
            (try! (as-contract (stx-transfer? payout tx-sender tx-sender)))
            ;; Zero out bet to prevent double claim
            (map-set bets { market-id: market-id, user: tx-sender, side: (get outcome market) } u0)
            (ok payout)
        )
    )
)
