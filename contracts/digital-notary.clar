;; Digital Notary & Document Verifier
;; Provide on-chain proof of existence and integrity for digital files
;; Built for Stacks Builder Challenge Week 3

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_DOC_ALREADY_NOTARIZED (err u402))
(define-constant ERR_DOC_NOT_FOUND (err u404))

(define-map notarized-docs
    (buff 32) ;; Hash of the document
    {
        owner: principal,
        block-height: uint,
        timestamp: uint,
        metadata: (string-ascii 256)
    }
)

;; Notarize a new document hash
(define-public (notarize-document (doc-hash (buff 32)) (metadata (string-ascii 256)))
    (begin
        (asserts! (is-none (map-get? notarized-docs doc-hash)) ERR_DOC_ALREADY_NOTARIZED)
        
        (map-set notarized-docs doc-hash {
            owner: tx-sender,
            block-height: stacks-block-height,
            timestamp: burn-block-height, ;; Real-world time reference
            metadata: metadata
        })
        
        (print {event: "document-notarized", hash: doc-hash, owner: tx-sender})
        (ok true)
    )
)

;; Verify document integrity
(define-read-only (verify-document (doc-hash (buff 32)))
    (ok (map-get? notarized-docs doc-hash))
)

;; Transfer document ownership (e.g., Intellectual Property)
(define-public (transfer-document-ownership (doc-hash (buff 32)) (new-owner principal))
    (let
        (
            (doc (unwrap! (map-get? notarized-docs doc-hash) ERR_DOC_NOT_FOUND))
        )
        (asserts! (is-eq (get owner doc) tx-sender) ERR_NOT_AUTHORIZED)
        
        (ok (map-set notarized-docs doc-hash (merge doc { owner: new-owner })))
    )
)
