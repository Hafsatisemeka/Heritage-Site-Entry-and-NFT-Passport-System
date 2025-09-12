(define-non-fungible-token heritage-passport uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-site (err u103))
(define-constant err-unauthorized (err u104))

(define-data-var passport-id-nonce uint u0)
(define-data-var site-id-nonce uint u0)
(define-data-var pricing-window uint u100)

(define-map heritage-sites uint {
    name: (string-ascii 50),
    location: (string-ascii 100),
    entry-fee: uint,
    active: bool
})

(define-map site-visits {passport-id: uint, site-id: uint} {
    visit-date: uint,
    stamped: bool
})

(define-map passport-details uint {
    owner: principal,
    issued-date: uint,
    visit-count: uint,
    tier: (string-ascii 10)
})

(define-map site-visit-counts {site-id: uint, window-start: uint} uint)

(define-map passport-nickname uint (string-ascii 20))


(define-read-only (get-passport-details (passport-id uint))
    (map-get? passport-details passport-id)
)

(define-read-only (get-site-details (site-id uint))
    (map-get? heritage-sites site-id)
)

(define-read-only (get-visit-details (passport-id uint) (site-id uint))
    (map-get? site-visits {passport-id: passport-id, site-id: site-id})
)

(define-private (get-current-window)
    (let ((window-size (var-get pricing-window)))
        (- burn-block-height (mod burn-block-height window-size))
    )
)

(define-read-only (get-popularity-score (site-id uint))
    (let (
        (current-window (get-current-window))
        (current-visits (default-to u0 (map-get? site-visit-counts {site-id: site-id, window-start: current-window})))
        (previous-window (- current-window (var-get pricing-window)))
        (previous-visits (default-to u0 (map-get? site-visit-counts {site-id: site-id, window-start: previous-window})))
    )
        (+ current-visits previous-visits)
    )
)

(define-private (get-price-multiplier (popularity uint))
    (if (>= popularity u20)
        u200
        (if (>= popularity u10)
            u150
            (if (>= popularity u5)
                u125
                u100
            )
        )
    )
)

(define-read-only (get-current-price (site-id uint))
    (let (
        (site (unwrap! (map-get? heritage-sites site-id) (err u0)))
        (base-fee (get entry-fee site))
        (popularity-score (get-popularity-score site-id))
    )
        (ok (* base-fee (get-price-multiplier popularity-score)))
    )
)

(define-read-only (get-nickname (passport-id uint))
    (map-get? passport-nickname passport-id)
)




(define-public (register-heritage-site (name (string-ascii 50)) (location (string-ascii 100)) (entry-fee uint))
    (let ((new-site-id (+ (var-get site-id-nonce) u1)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set heritage-sites new-site-id {
            name: name,
            location: location,
            entry-fee: entry-fee,
            active: true
        })
        (var-set site-id-nonce new-site-id)
        (ok new-site-id)
    )
)

(define-public (mint-passport)
    (let ((new-passport-id (+ (var-get passport-id-nonce) u1)))
        (try! (nft-mint? heritage-passport new-passport-id tx-sender))
        (map-set passport-details new-passport-id {
            owner: tx-sender,
            issued-date: burn-block-height,
            visit-count: u0,
            tier: "BRONZE"
        })
        (var-set passport-id-nonce new-passport-id)
        (ok new-passport-id)
    )
)

(define-private (update-visit-count (site-id uint))
    (let (
        (current-window (get-current-window))
        (current-count (default-to u0 (map-get? site-visit-counts {site-id: site-id, window-start: current-window})))
    )
        (map-set site-visit-counts {site-id: site-id, window-start: current-window} (+ current-count u1))
    )
)



(define-public (record-visit (passport-id uint) (site-id uint))
    (let (
        (passport-owner (unwrap! (nft-get-owner? heritage-passport passport-id) err-not-found))
        (site (unwrap! (map-get? heritage-sites site-id) err-invalid-site))
        (current-details (unwrap! (map-get? passport-details passport-id) err-not-found))
    )
        (asserts! (is-eq tx-sender passport-owner) err-unauthorized)
        (asserts! (get active site) err-invalid-site)
        
        (map-set site-visits {passport-id: passport-id, site-id: site-id} {
            visit-date: burn-block-height,
            stamped: true
        })
        
        (update-visit-count site-id)
        
        (map-set passport-details passport-id 
            (merge current-details {
                visit-count: (+ (get visit-count current-details) u1),
                tier: (calculate-tier (+ (get visit-count current-details) u1))
            })
        )
        (ok true)
    )
)

(define-private (calculate-tier (visits uint))
    (if (>= visits u10)
        "GOLD"
        (if (>= visits u5)
            "SILVER"
            "BRONZE"
        )
    )
)


(define-public (deactivate-site (site-id uint))
    (let ((site (unwrap! (map-get? heritage-sites site-id) err-not-found)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set heritage-sites site-id (merge site {active: false}))
        (ok true)
    )
)

(define-public (transfer-passport (passport-id uint) (recipient principal))
    (let ((owner (unwrap! (nft-get-owner? heritage-passport passport-id) err-not-found)))
        (asserts! (is-eq tx-sender owner) err-unauthorized)
        (try! (nft-transfer? heritage-passport passport-id tx-sender recipient))
        (ok true)
    )
)

(define-public (set-nickname (passport-id uint) (nickname (string-ascii 20)))
    (let ((owner (unwrap! (nft-get-owner? heritage-passport passport-id) err-not-found)))
        (asserts! (is-eq tx-sender owner) err-unauthorized)
        (map-set passport-nickname passport-id nickname)
        (ok true)
    )
)