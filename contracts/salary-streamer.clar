;; Decentralized Salary Streamer & Payroll
;; Enable real-time salary payments and automated payroll on-chain
;; Built for Stacks Builder Challenge Week 3

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_STREAM_NOT_FOUND (err u404))
(define-constant ERR_INSUFFICIENT_FUNDS (err u403))

(define-map streams
    uint
    {
        sender: principal,
        recipient: principal,
        amount-total: uint,
        amount-withdrawn: uint,
        start-block: uint,
        stop-block: uint
    }
)

(define-data-var stream-nonce uint u0)

;; Create a new payment stream
(define-public (create-stream (recipient principal) (amount uint) (duration uint))
    (let
        (
            (stream-id (+ (var-get stream-nonce) u1))
        )
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        (map-set streams stream-id {
            sender: tx-sender,
            recipient: recipient,
            amount-total: amount,
            amount-withdrawn: u0,
            start-block: stacks-block-height,
            stop-block: (+ stacks-block-height duration)
        })
        
        (var-set stream-nonce stream-id)
        (print {event: "stream-created", id: stream-id, recipient: recipient})
        (ok stream-id)
    )
)

;; Withdraw available salary from stream
(define-public (withdraw-from-stream (stream-id uint))
    (let
        (
            (stream (unwrap! (map-get? streams stream-id) ERR_STREAM_NOT_FOUND))
            (available (calculate-available stream-id))
        )
        (asserts! (is-eq (get recipient stream) tx-sender) ERR_NOT_AUTHORIZED)
        (asserts! (> available u0) ERR_INSUFFICIENT_FUNDS)
        
        (try! (as-contract (stx-transfer? available (as-contract tx-sender) tx-sender)))
        
        (map-set streams stream-id (merge stream {
            amount-withdrawn: (+ (get amount-withdrawn stream) available)
        }))
        
        (ok available)
    )
)

;; Calculate available funds to withdraw based on block progression
(define-read-only (calculate-available (stream-id uint))
    (let
        (
            (stream (unwrap! (map-get? streams stream-id) u0))
            (current-block stacks-block-height)
        )
        (if (>= current-block (get stop-block stream))
            (- (get amount-total stream) (get amount-withdrawn stream))
            (let
                (
                    (elapsed (- current-block (get start-block stream)))
                    (duration (- (get stop-block stream) (get start-block stream)))
                    (total-vested (/ (* (get amount-total stream) elapsed) duration))
                )
                (- total-vested (get amount-withdrawn stream))
            )
        )
    )
)
