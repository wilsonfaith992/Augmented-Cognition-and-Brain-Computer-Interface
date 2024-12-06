;; Performance Rewards Contract

(define-fungible-token cognition-token)

(define-map user-achievements
  { user: principal }
  { milestones-reached: uint }
)

(define-constant reward-amount u100)

(define-public (claim-achievement (performance-score int))
  (let
    ((user-data (default-to { milestones-reached: u0 } (map-get? user-achievements { user: tx-sender }))))
    (if (and
          (> performance-score 100)
          (is-eq (mod (+ (get milestones-reached user-data) u1) u5) u0))
      (begin
        (try! (ft-mint? cognition-token reward-amount tx-sender))
        (ok (map-set user-achievements
          { user: tx-sender }
          { milestones-reached: (+ (get milestones-reached user-data) u1) }
        ))
      )
      (err u403)
    )
  )
)

(define-read-only (get-user-achievements (user principal))
  (ok (map-get? user-achievements { user: user }))
)

(define-read-only (get-token-balance (user principal))
  (ok (ft-get-balance cognition-token user))
)

