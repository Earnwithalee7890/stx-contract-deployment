
;; identity-registry.clar
;; Stores identity verification data on-chain.
;; Clarity 4

(define-constant err-not-found (err u1000))
(define-constant err-permission-denied (err u1001))

(define-map identities 
    principal 
    {
        username: (string-utf8 50),
        metadata-hash: (buff 32),
        verified: bool
    }
)

(define-data-var registrar principal tx-sender)

(define-public (register-identity (username (string-utf8 50)) (hash (buff 32)))
    (begin
        (map-set identities tx-sender {
            username: username,
            metadata-hash: hash,
            verified: false
        })
        (ok true)
    )
)

(define-public (verify-identity (user principal))
    (let
        (
            (identity (unwrap! (map-get? identities user) err-not-found))
        )
        (asserts! (is-eq tx-sender (var-get registrar)) err-permission-denied)
        (map-set identities user (merge identity { verified: true }))
        (ok true)
    )
)

(define-read-only (get-identity (user principal))
    (map-get? identities user)
)

(define-public (update-metadata (hash (buff 32)))
    (let
        (
            (identity (unwrap! (map-get? identities tx-sender) err-not-found))
        )
        (map-set identities tx-sender (merge identity { metadata-hash: hash }))
        (ok true)
    )
)

(define-public (transfer-registrar (new-registrar principal))
    (begin
        (asserts! (is-eq tx-sender (var-get registrar)) err-permission-denied)
        (var-set registrar new-registrar)
        (ok true)
    )
)
