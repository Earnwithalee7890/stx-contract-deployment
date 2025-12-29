;; title: Milestone Badges (SIP-009)
;; version: 1.0.0
;; summary: NFT badges for reaching milestones

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token milestone-badge uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Data Vars
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 256) "https://badges.stacksbuilder.com/metadata/")

;; NFT Trait Implementation
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (id uint))
    (ok (some (var-get base-uri)))
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? milestone-badge id))
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? milestone-badge id sender recipient)
    )
)

;; Public Functions

;; Mint a badge (restricted to owner or authorized contracts in production)
(define-public (mint-badge (recipient principal) (badge-type uint))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? milestone-badge token-id recipient))
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

;; Admin Functions
(define-public (set-base-uri (new-uri (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set base-uri new-uri)
        (ok true)
    )
)
