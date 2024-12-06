;; Cognitive Enhancement Marketplace Contract

(define-map marketplace-listings
  { listing-id: uint }
  {
    app-id: uint,
    seller: principal,
    price: uint,
    description: (string-utf8 256),
    status: (string-ascii 20)
  }
)

(define-data-var next-listing-id uint u0)

(define-public (create-listing (app-id uint) (price uint) (description (string-utf8 256)))
  (let
    ((listing-id (+ (var-get next-listing-id) u1)))
    (map-set marketplace-listings
      { listing-id: listing-id }
      {
        app-id: app-id,
        seller: tx-sender,
        price: price,
        description: description,
        status: "active"
      }
    )
    (var-set next-listing-id listing-id)
    (ok listing-id)
  )
)

(define-public (purchase-listing (listing-id uint))
  (let
    ((listing (unwrap! (map-get? marketplace-listings { listing-id: listing-id }) (err u404))))
    (asserts! (is-eq (get status listing) "active") (err u400))
    (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
    (ok (map-set marketplace-listings
      { listing-id: listing-id }
      (merge listing { status: "sold" })
    ))
  )
)

(define-read-only (get-listing (listing-id uint))
  (ok (map-get? marketplace-listings { listing-id: listing-id }))
)

