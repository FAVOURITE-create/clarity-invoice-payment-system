;; Define data structures for invoices
(define-map invoices
    { invoice-id: uint }
    {
        amount: uint,
        sender: principal,
        recipient: principal,
        due-date: uint,
        paid: bool,
        cancelled: bool
    }
)

;; Keep track of invoice count
(define-data-var invoice-counter uint u0)

;; Error codes
(define-constant err-not-authorized (err u100))
(define-constant err-invoice-not-found (err u101))
(define-constant err-already-paid (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-past-due (err u104))
(define-constant err-cancelled (err u105))

;; Create a new invoice
(define-public (create-invoice (amount uint) (recipient principal) (due-date uint))
    (let ((invoice-id (var-get invoice-counter)))
        (map-insert invoices
            { invoice-id: invoice-id }
            {
                amount: amount,
                sender: tx-sender,
                recipient: recipient,
                due-date: due-date,
                paid: false,
                cancelled: false
            }
        )
        (var-set invoice-counter (+ invoice-id u1))
        (ok invoice-id)
    )
)

;; Pay an invoice
(define-public (pay-invoice (invoice-id uint))
    (let (
        (invoice (unwrap! (map-get? invoices {invoice-id: invoice-id}) err-invoice-not-found))
        (current-time (unwrap-panic (get-block-info? time u0)))
    )
        (asserts! (not (get paid invoice)) err-already-paid)
        (asserts! (not (get cancelled invoice)) err-cancelled)
        (asserts! (<= current-time (get due-date invoice)) err-past-due)
        (try! (stx-transfer? (get amount invoice) tx-sender (get recipient invoice)))
        (map-set invoices 
            {invoice-id: invoice-id}
            (merge invoice {paid: true})
        )
        (ok true)
    )
)

;; Cancel an invoice - only creator can cancel
(define-public (cancel-invoice (invoice-id uint))
    (let ((invoice (unwrap! (map-get? invoices {invoice-id: invoice-id}) err-invoice-not-found)))
        (asserts! (is-eq (get sender invoice) tx-sender) err-not-authorized)
        (asserts! (not (get paid invoice)) err-already-paid)
        (map-set invoices 
            {invoice-id: invoice-id}
            (merge invoice {cancelled: true})
        )
        (ok true)
    )
)

;; Read only functions
(define-read-only (get-invoice (invoice-id uint))
    (ok (map-get? invoices {invoice-id: invoice-id}))
)

(define-read-only (get-invoice-count)
    (ok (var-get invoice-counter))
)
