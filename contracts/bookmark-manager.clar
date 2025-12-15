;; Bookmark Manager
(define-map bookmarks {user: principal, item-id: uint} bool)

(define-public (add-bookmark (item-id uint))
  (ok (map-set bookmarks {user: tx-sender, item-id: item-id} true))
)

(define-read-only (is-bookmarked (user principal) (item-id uint))
  (default-to false (map-get? bookmarks {user: user, item-id: item-id}))
)
