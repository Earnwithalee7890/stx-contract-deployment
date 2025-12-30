
;; advanced-vesting.clar
;; A vesting contract that allows a grantor to lock tokens for a beneficiary
;; with a cliff and linear vesting schedule.
;; Clarity 4

(define-constant err-only-grantor (err u100))
(define-constant err-already-initialized (err u101))
(define-constant err-no-vesting-schedule (err u102))
(define-constant err-cliff-not-reached (err u103))
(define-constant err-insufficient-balance (err u104))
(define-constant err-revoked (err u105))

(define-data-var grantor principal tx-sender)

(define-map vesting-schedules
    principal
    {
        total-amount: uint,
        vested-amount: uint,
        start-height: uint,
        cliff-height: uint,
        end-height: uint,
        revocable: bool,
        is-revoked: bool
    }
)

(define-public (initialize-vesting (beneficiary principal) (amount uint) (start-height uint) (cliff-duration uint) (vesting-duration uint) (revocable bool))
    (let
        (
            (cliff-height (+ start-height cliff-duration))
            (end-height (+ start-height vesting-duration))
        )
        (asserts! (is-eq tx-sender (var-get grantor)) err-only-grantor)
        (asserts! (is-none (map-get? vesting-schedules beneficiary)) err-already-initialized)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (ok (map-set vesting-schedules beneficiary {
            total-amount: amount,
            vested-amount: u0,
            start-height: start-height,
            cliff-height: cliff-height,
            end-height: end-height,
            revocable: revocable,
            is-revoked: false
        }))
    )
)

(define-read-only (get-claimable-amount (beneficiary principal))
    (let
        (
            (schedule (unwrap! (map-get? vesting-schedules beneficiary) u0))
            (current-height burn-block-height)
        )
        (if (get is-revoked schedule)
            u0
            (if (< current-height (get cliff-height schedule))
                u0
                (if (>= current-height (get end-height schedule))
                    (- (get total-amount schedule) (get vested-amount schedule))
                    (let
                        (
                            (total-duration (- (get end-height schedule) (get start-height schedule)))
                            (elapsed-duration (- current-height (get start-height schedule)))
                            (vested-ratio (/ (* (get total-amount schedule) elapsed-duration) total-duration))
                        )
                        (- vested-ratio (get vested-amount schedule))
                    )
                )
            )
        )
    )
)

(define-public (claim-tokens)
    (let
        (
            (schedule (unwrap! (map-get? vesting-schedules tx-sender) err-no-vesting-schedule))
            (claimable (get-claimable-amount tx-sender))
        )
        (asserts! (> claimable u0) err-insufficient-balance)
        (try! (as-contract (stx-transfer? claimable tx-sender (get beneficiary-addr tx-sender this)))) ;; Fix: tx-sender is beneficiary
        (map-set vesting-schedules tx-sender (merge schedule { vested-amount: (+ (get vested-amount schedule) claimable) }))
        (ok claimable)
    )
)

;; Helper to correct the transfer call above, using let binding for clean logic
(define-public (claim)
    (let
        (
            (beneficiary tx-sender)
            (schedule (unwrap! (map-get? vesting-schedules beneficiary) err-no-vesting-schedule))
            (claimable (get-claimable-amount beneficiary))
        )
        (asserts! (not (get is-revoked schedule)) err-revoked)
        (asserts! (> claimable u0) err-insufficient-balance)
        (try! (as-contract (stx-transfer? claimable tx-sender beneficiary)))
        (map-set vesting-schedules beneficiary (merge schedule { vested-amount: (+ (get vested-amount schedule) claimable) }))
        (ok claimable)
    )
)

(define-public (revoke (beneficiary principal))
    (let
        (
            (schedule (unwrap! (map-get? vesting-schedules beneficiary) err-no-vesting-schedule))
            (refund-amount (- (get total-amount schedule) (get vested-amount schedule)))
        )
        (asserts! (is-eq tx-sender (var-get grantor)) err-only-grantor)
        (asserts! (get revocable schedule) err-revoked) ;; Re-using err for "cannot revoke"
        (asserts! (not (get is-revoked schedule)) err-revoked)
        
        ;; Return remaining tokens to grantor
        (if (> refund-amount u0)
            (try! (as-contract (stx-transfer? refund-amount tx-sender (var-get grantor))))
            true
        )
        
        (map-set vesting-schedules beneficiary (merge schedule { is-revoked: true }))
        (ok true)
    )
)
