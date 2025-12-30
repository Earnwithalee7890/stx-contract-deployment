
;; dao-governance.clar
;; A simple DAO governance contract for submitting and voting on proposals.
;; Clarity 4

(define-constant err-not-member (err u400))
(define-constant err-proposal-not-found (err u401))
(define-constant err-proposal-expired (err u402))
(define-constant err-already-voted (err u403))
(define-constant err-insufficient-votes (err u404))
(define-constant voting-period u144) ;; ~1 day in blocks

(define-map members principal bool)
(define-map proposals 
    uint 
    {
        proposer: principal,
        title: (string-utf8 50),
        description: (string-utf8 256),
        start-block: uint,
        end-block: uint,
        yes-votes: uint,
        no-votes: uint,
        executed: bool
    }
)

(define-map votes { proposal-id: uint, voter: principal } bool)

(define-data-var proposal-count uint u0)

(define-public (add-member (new-member principal))
    (begin
        ;; In a real DAO, this would be restricted to execute by the DAO contract itself
        ;; For this example, we assume deployer can add initial members
        (map-set members new-member true)
        (ok true)
    )
)

(define-public (submit-proposal (title (string-utf8 50)) (description (string-utf8 256)))
    (let
        (
            (new-id (+ (var-get proposal-count) u1))
        )
        (asserts! (default-to false (map-get? members tx-sender)) err-not-member)
        
        (map-set proposals new-id {
            proposer: tx-sender,
            title: title,
            description: description,
            start-block: burn-block-height,
            end-block: (+ burn-block-height voting-period),
            yes-votes: u0,
            no-votes: u0,
            executed: false
        })
        (var-set proposal-count new-id)
        (ok new-id)
    )
)

(define-public (vote (proposal-id uint) (vote-for bool))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
        )
        (asserts! (default-to false (map-get? members tx-sender)) err-not-member)
        (asserts! (< burn-block-height (get end-block proposal)) err-proposal-expired)
        (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) err-already-voted)
        
        (map-set votes { proposal-id: proposal-id, voter: tx-sender } true)
        (if vote-for
            (map-set proposals proposal-id (merge proposal { yes-votes: (+ (get yes-votes proposal) u1) }))
            (map-set proposals proposal-id (merge proposal { no-votes: (+ (get no-votes proposal) u1) }))
        )
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
        )
        (asserts! (>= burn-block-height (get end-block proposal)) err-proposal-expired) ;; Wait until voting ends
        (asserts! (> (get yes-votes proposal) (get no-votes proposal)) err-insufficient-votes)
        (asserts! (not (get executed proposal)) (err u405))
        
        ;; Execution logic would go here (e.g. contract-calls)
        
        (map-set proposals proposal-id (merge proposal { executed: true }))
        (ok true)
    )
)
