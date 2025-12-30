
;; nft-marketplace-v2.clar
;; A standard non-custodial NFT marketplace
;; Clarity 4

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant err-not-owner (err u700))
(define-constant err-price-zero (err u701))
(define-constant err-listing-not-found (err u702))
(define-constant err-wrong-contract (err u703))

(define-map listings
    { nft-contract: principal, token-id: uint }
    { seller: principal, price: uint }
)

(define-public (list-asset (nft-contract <nft-trait>) (token-id uint) (price uint))
    (let
        (
            (owner (unwrap! (contract-call? nft-contract get-owner token-id) (err u704)))
        )
        (asserts! (is-eq (some tx-sender) owner) err-not-owner)
        (asserts! (> price u0) err-price-zero)
        
        ;; In a real marketplace, we might transfer to escrow or verify approval.
        ;; For non-custodial, we trust the transfer will work on buy-asset if approved.
        
        (map-set listings { nft-contract: (contract-of nft-contract), token-id: token-id } { seller: tx-sender, price: price })
        (ok true)
    )
)

(define-public (buy-asset (nft-contract <nft-trait>) (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? listings { nft-contract: (contract-of nft-contract), token-id: token-id }) err-listing-not-found))
            (price (get price listing))
            (seller (get seller listing))
        )
        (asserts! (is-eq (contract-of nft-contract) (contract-of nft-contract)) err-wrong-contract)
        
        (try! (stx-transfer? price tx-sender seller))
        (try! (contract-call? nft-contract transfer token-id seller tx-sender))
        
        (map-delete listings { nft-contract: (contract-of nft-contract), token-id: token-id })
        (ok true)
    )
)

(define-public (unlist-asset (nft-contract <nft-trait>) (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? listings { nft-contract: (contract-of nft-contract), token-id: token-id }) err-listing-not-found))
        )
        (asserts! (is-eq tx-sender (get seller listing)) err-not-owner)
        (map-delete listings { nft-contract: (contract-of nft-contract), token-id: token-id })
        (ok true)
    )
)
