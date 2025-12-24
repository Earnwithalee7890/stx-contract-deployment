;; Testnet Check-In & Badges System
;; Daily check-ins + Weekly badges for testing on Stacks Testnet
;; Fee: 0.001 STX (testnet friendly)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_ALREADY_CHECKED_IN (err u100))
(define-constant ERR_ALREADY_EARNED_BADGE (err u101))
(define-constant ERR_INSUFFICIENT_FEE (err u102))

;; Lower fee for testnet (0.001 STX)
(define-constant CHECK_IN_FEE u1000) ;; 0.001 STX
(define-constant BADGE_FEE u1000) ;; 0.001 STX

;; Fee recipient (change to your testnet address)
(define-constant FEE_RECIPIENT 'ST2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT)

;; Stats tracking
(define-data-var total-check-ins uint u0)
(define-data-var total-badges-earned uint u0)
(define-data-var total-users uint u0)

;; User check-in data
(define-map user-check-ins
    principal
    {
        total-check-ins: uint,
        last-check-in-day: uint,
        streak: uint,
        total-badges: uint
    }
)

;; Daily check-in tracking (user -> day -> checked-in)
(define-map daily-check-ins
    {user: principal, day: uint}
    {timestamp: uint}
)

;; Weekly badges (user -> day-of-week -> earned)
(define-map weekly-badges
    {user: principal, day-of-week: uint}
    {earned-at: uint, week-number: uint}
)

;; Badge names
(define-constant BADGE_NAMES (list 
    "Monday Warrior"
    "Tuesday Titan"
    "Wednesday Winner"
    "Thursday Thunder"
    "Friday Fire"
    "Saturday Star"
    "Sunday Champion"
))

;; Helper functions
(define-private (get-current-day)
    (/ stacks-block-height u144) ;; ~144 blocks = 1 day
)

(define-private (get-day-of-week)
    (mod (/ stacks-block-height u144) u7) ;; 0=Monday, 6=Sunday
)

(define-private (get-week-number)
    (/ stacks-block-height u1008) ;; ~7 days
)

;; Main check-in function
(define-public (check-in)
    (let
        (
            (current-day (get-current-day))
            (user-data (default-to 
                {total-check-ins: u0, last-check-in-day: u0, streak: u0, total-badges: u0}
                (map-get? user-check-ins tx-sender)))
            (already-checked (map-get? daily-check-ins {user: tx-sender, day: current-day}))
        )
        ;; Verify not already checked in today
        (asserts! (is-none already-checked) ERR_ALREADY_CHECKED_IN)
        
        ;; Collect fee
        (try! (stx-transfer? CHECK_IN_FEE tx-sender FEE_RECIPIENT))
        
        ;; Calculate streak
        (let
            (
                (is-consecutive (is-eq (get last-check-in-day user-data) (- current-day u1)))
                (new-streak (if is-consecutive 
                    (+ (get streak user-data) u1)
                    u1
                ))
            )
            ;; Record check-in
            (map-set daily-check-ins {user: tx-sender, day: current-day} {
                timestamp: stacks-block-height
            })
            
            ;; Update user stats
            (map-set user-check-ins tx-sender {
                total-check-ins: (+ (get total-check-ins user-data) u1),
                last-check-in-day: current-day,
                streak: new-streak,
                total-badges: (get total-badges user-data)
            })
            
            ;; Update global stats
            (if (is-eq (get total-check-ins user-data) u0)
                (var-set total-users (+ (var-get total-users) u1))
                true
            )
            (var-set total-check-ins (+ (var-get total-check-ins) u1))
            
            (ok {
                check-ins: (+ (get total-check-ins user-data) u1),
                streak: new-streak,
                day: current-day
            })
        )
    )
)

;; Earn daily badge
(define-public (earn-badge)
    (let
        (
            (current-day-of-week (get-day-of-week))
            (current-week (get-week-number))
            (existing-badge (map-get? weekly-badges {user: tx-sender, day-of-week: current-day-of-week}))
            (user-data (default-to 
                {total-check-ins: u0, last-check-in-day: u0, streak: u0, total-badges: u0}
                (map-get? user-check-ins tx-sender)))
        )
        ;; Check if already earned this week
        (asserts! 
            (or 
                (is-none existing-badge)
                (not (is-eq (get week-number (unwrap-panic existing-badge)) current-week))
            )
            ERR_ALREADY_EARNED_BADGE
        )
        
        ;; Collect badge fee
        (try! (stx-transfer? BADGE_FEE tx-sender FEE_RECIPIENT))
        
        ;; Award badge
        (map-set weekly-badges {user: tx-sender, day-of-week: current-day-of-week} {
            earned-at: stacks-block-height,
            week-number: current-week
        })
        
        ;; Update user badge count
        (map-set user-check-ins tx-sender 
            (merge user-data {total-badges: (+ (get total-badges user-data) u1)})
        )
        
        (var-set total-badges-earned (+ (var-get total-badges-earned) u1))
        
        (ok {
            day-of-week: current-day-of-week,
            week: current-week,
            badge-name: (unwrap-panic (element-at BADGE_NAMES current-day-of-week))
        })
    )
)

;; Read-only functions
(define-read-only (get-user-stats (user principal))
    (ok (map-get? user-check-ins user))
)

(define-read-only (get-current-day-info)
    (ok {
        day: (get-current-day),
        day-of-week: (get-day-of-week),
        week-number: (get-week-number)
    })
)

(define-read-only (has-checked-in-today (user principal))
    (let ((current-day (get-current-day)))
        (ok (is-some (map-get? daily-check-ins {user: user, day: current-day})))
    )
)

(define-read-only (get-badge-status (user principal) (day-of-week uint))
    (ok (map-get? weekly-badges {user: user, day-of-week: day-of-week}))
)

(define-read-only (get-weekly-progress (user principal))
    (ok {
        monday: (is-some (map-get? weekly-badges {user: user, day-of-week: u0})),
        tuesday: (is-some (map-get? weekly-badges {user: user, day-of-week: u1})),
        wednesday: (is-some (map-get? weekly-badges {user: user, day-of-week: u2})),
        thursday: (is-some (map-get? weekly-badges {user: user, day-of-week: u3})),
        friday: (is-some (map-get? weekly-badges {user: user, day-of-week: u4})),
        saturday: (is-some (map-get? weekly-badges {user: user, day-of-week: u5})),
        sunday: (is-some (map-get? weekly-badges {user: user, day-of-week: u6}))
    })
)

(define-read-only (get-global-stats)
    (ok {
        total-check-ins: (var-get total-check-ins),
        total-badges: (var-get total-badges-earned),
        total-users: (var-get total-users)
    })
)

(define-read-only (get-badge-name (day-of-week uint))
    (ok (unwrap-panic (element-at BADGE_NAMES day-of-week)))
)
