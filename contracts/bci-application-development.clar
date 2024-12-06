;; BCI Application Development Contract

(define-map applications
  { app-id: uint }
  {
    name: (string-ascii 64),
    developer: principal,
    collaborators: (list 10 principal),
    status: (string-ascii 20),
    version: (string-ascii 20)
  }
)

(define-data-var next-app-id uint u0)

(define-public (create-application (name (string-ascii 64)))
  (let
    ((app-id (+ (var-get next-app-id) u1)))
    (map-set applications
      { app-id: app-id }
      {
        name: name,
        developer: tx-sender,
        collaborators: (list tx-sender),
        status: "development",
        version: "0.1"
      }
    )
    (var-set next-app-id app-id)
    (ok app-id)
  )
)

(define-public (add-collaborator (app-id uint) (collaborator principal))
  (let
    ((app (unwrap! (map-get? applications { app-id: app-id }) (err u404))))
    (asserts! (is-eq (get developer app) tx-sender) (err u403))
    (ok (map-set applications
      { app-id: app-id }
      (merge app { collaborators: (unwrap! (as-max-len? (append (get collaborators app) collaborator) u10) (err u400)) })
    ))
  )
)

(define-public (update-app-status (app-id uint) (new-status (string-ascii 20)))
  (let
    ((app (unwrap! (map-get? applications { app-id: app-id }) (err u404))))
    (asserts! (is-eq (get developer app) tx-sender) (err u403))
    (ok (map-set applications
      { app-id: app-id }
      (merge app { status: new-status })
    ))
  )
)

(define-read-only (get-application (app-id uint))
  (ok (map-get? applications { app-id: app-id }))
)

