;; Device Integration Contract

(define-map integrated-devices
  { device-id: (string-ascii 64) }
  {
    user: principal,
    device-type: (string-ascii 64),
    last-sync: uint
  }
)

(define-public (register-device (device-id (string-ascii 64)) (device-type (string-ascii 64)))
  (ok (map-set integrated-devices
    { device-id: device-id }
    {
      user: tx-sender,
      device-type: device-type,
      last-sync: block-height
    }
  ))
)

(define-public (update-device-sync (device-id (string-ascii 64)))
  (let
    ((device (unwrap! (map-get? integrated-devices { device-id: device-id }) (err u404))))
    (asserts! (is-eq (get user device) tx-sender) (err u403))
    (ok (map-set integrated-devices
      { device-id: device-id }
      (merge device { last-sync: block-height })
    ))
  )
)

(define-read-only (get-device-info (device-id (string-ascii 64)))
  (ok (map-get? integrated-devices { device-id: device-id }))
)

