;; Cognitive Data Storage Contract

(define-map cognitive-data
  { user-id: principal }
  {
    performance-data: (list 100 int),
    last-updated: uint
  }
)

(define-data-var data-access-log (list 1000 { user: principal, accessed: principal, timestamp: uint }) (list))

(define-public (store-performance-data (performance-score int))
  (let
    ((current-data (default-to { performance-data: (list), last-updated: u0 } (map-get? cognitive-data { user-id: tx-sender })))
     (updated-data (append (get performance-data current-data) performance-score)))
    (ok (map-set cognitive-data
      { user-id: tx-sender }
      {
        performance-data: (unwrap-panic (as-max-len?
                            (if (> (len updated-data) u100)
                              (unwrap-panic (slice? updated-data u1 u101))
                              updated-data)
                            u100)),
        last-updated: block-height
      }
    ))
  )
)

(define-read-only (get-performance-data (user principal))
  (ok (map-get? cognitive-data { user-id: user }))
)

(define-public (log-data-access (accessed-user principal))
  (let
    ((new-log-entry { user: tx-sender, accessed: accessed-user, timestamp: block-height })
     (current-log (var-get data-access-log))
     (updated-log (unwrap-panic (as-max-len? (append current-log new-log-entry) u1000))))
    (ok (var-set data-access-log updated-log))
  )
)

(define-read-only (get-access-log)
  (ok (var-get data-access-log))
)

