
;; bonding-curve-token.clar
;; A token where the price is determined by the supply using a linear bonding curve.
;; Price = m * supply + b
;; Clarity 4

(define-constant err-slippage (err u300))
(define-constant err-insufficient-funds (err u301))

(define-token bonding-token)
(define-data-var reserve-balance uint u0)

;; Curve parameters
;; slope (m) scaled by 1000000 for precision
(define-constant slope u100) 
;; base price (b)
(define-constant base-price u1000)

(define-read-only (get-total-supply)
    (ft-get-supply bonding-token)
)

(define-read-only (get-price-optimistic (supply uint))
    (+ base-price (/ (* slope supply) u1000000))
)

(define-read-only (get-buy-price (amount uint))
    (let
        (
            (current-supply (get-total-supply))
            (new-supply (+ current-supply amount))
            ;; Integral of linear function mx+b is (m/2)x^2 + bx
            ;; Cost = Integral(new) - Integral(current)
            (cost-new (+ (* base-price new-supply) (/ (* slope new-supply new-supply) u2000000)))
            (cost-current (+ (* base-price current-supply) (/ (* slope current-supply current-supply) u2000000)))
        )
        (- cost-new cost-current)
    )
)

(define-read-only (get-sell-price (amount uint))
    (let
        (
            (current-supply (get-total-supply))
            (new-supply (- current-supply amount))
            (cost-new (+ (* base-price new-supply) (/ (* slope new-supply new-supply) u2000000)))
            (cost-current (+ (* base-price current-supply) (/ (* slope current-supply current-supply) u2000000)))
        )
        (- cost-current cost-new)
    )
)

(define-public (mint (amount uint) (max-spend uint))
    (let
        (
            (cost (get-buy-price amount))
        )
        (asserts! (<= cost max-spend) err-slippage)
        (try! (stx-transfer? cost tx-sender (as-contract tx-sender)))
        (try! (ft-mint? bonding-token amount tx-sender))
        (var-set reserve-balance (+ (var-get reserve-balance) cost))
        (ok cost)
    )
)

(define-public (burn (amount uint) (min-return uint))
    (let
        (
            (return (get-sell-price amount))
        )
        (asserts! (>= return min-return) err-slippage)
        (try! (ft-burn? bonding-token amount tx-sender))
        (try! (as-contract (stx-transfer? return tx-sender tx-sender)))
        (var-set reserve-balance (- (var-get reserve-balance) return))
        (ok return)
    )
)
