;; Advanced NFT Minter (SIP-009)
;; Featuring Clarity 4 standards and metadata management
;; Built for Stacks Builder Challenge Week 3

;; (impl-trait .sip009-nft-trait.sip009-nft-trait)

(define-non-fungible-token builder-nft uint)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_OWNER (err u402))
(define-constant ERR_METADATA_LOCKED (err u403))

;; Variables
(define-data-var last-token-id uint u0)
(define-data-var collection-uri (optional (string-ascii 256)) none)
(define-data-var metadata-frozen bool false)

;; Maps
(define-map token-uris uint (string-ascii 256))

;; SIP-009 Read-only functions
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (default-to "" (map-get? token-uris token-id))))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? builder-nft token-id))
)

;; SIP-009 Public functions
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_NOT_OWNER)
        (nft-transfer? builder-nft token-id sender recipient)
    )
)

;; Minting logic
(define-public (mint (recipient principal) (uri (string-ascii 256)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        
        (try! (nft-mint? builder-nft token-id recipient))
        (map-set token-uris token-id uri)
        (var-set last-token-id token-id)
        
        (print {event: "nft-mint", token-id: token-id, recipient: recipient})
        (ok token-id)
    )
)

;; Metadata management
(define-public (freeze-metadata)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set metadata-frozen true)
        (ok true)
    )
)

(define-public (update-token-uri (token-id uint) (new-uri (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (not (var-get metadata-frozen)) ERR_METADATA_LOCKED)
        (map-set token-uris token-id new-uri)
        (ok true)
    )
)
