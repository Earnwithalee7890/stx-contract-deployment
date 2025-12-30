
;; subscription-payments.clar
;; Allows users to subscribe to a service and enables the service provider to pull payments periodically.
;; Clarity 4

(define-constant err-subscription-not-found (err u800))
(define-constant err-payment-too-early (err u801))
(define-constant err-amount-too-high (err u802))
(define-constant err-unauthorized (err u803))

(define-map subscriptions 
    { subscriber: principal, provider: principal }
    {
        max-amount: uint,
        period: uint, ;; in blocks
        last-payment-block: uint,
        active: bool
    }
)

(define-public (subscribe (provider principal) (max-amount uint) (period uint))
    (begin
        (map-set subscriptions { subscriber: tx-sender, provider: provider } {
            max-amount: max-amount,
            period: period,
            last-payment-block: burn-block-height,
            active: true
        })
        (ok true)
    )
)

(define-public (unsubscribe (provider principal))
    (let
        (
            (sub (unwrap! (map-get? subscriptions { subscriber: tx-sender, provider: provider }) err-subscription-not-found))
        )
        (map-set subscriptions { subscriber: tx-sender, provider: provider } (merge sub { active: false }))
        (ok true)
    )
)

(define-public (process-payment (subscriber principal) (amount uint))
    (let
        (
            (sub (unwrap! (map-get? subscriptions { subscriber: subscriber, provider: tx-sender }) err-subscription-not-found))
            (next-valid-block (+ (get last-payment-block sub) (get period sub)))
        )
        (asserts! (get active sub) err-subscription-not-found)
        (asserts! (>= burn-block-height next-valid-block) err-payment-too-early)
        (asserts! (<= amount (get max-amount sub)) err-amount-too-high)
        
        (try! (stx-transfer? amount subscriber tx-sender))
        
        (map-set subscriptions { subscriber: subscriber, provider: tx-sender } (merge sub { last-payment-block: burn-block-height }))
        (ok true)
    )
)
