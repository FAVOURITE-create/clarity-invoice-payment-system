# Automated Invoice Payment System

A blockchain-based invoice payment system that allows users to:

- Create invoices with specified amounts and due dates
- Pay invoices using STX tokens
- Cancel unpaid invoices
- Track payment status
- Validate payments against due dates
- Create recurrent invoices with automatic renewal
- Add payment memos for better tracking

Built with Clarity on the Stacks blockchain.

## Features

- Automated payment validation
- Due date enforcement
- Payment status tracking
- Invoice cancellation
- Secure and transparent transactions
- Recurrent invoice support
- Payment memos support

## Recurrent Invoices

The system now supports automatic creation of recurrent invoices. When a recurrent invoice is paid,
a new invoice is automatically created with:
- Same amount
- Same recipient
- Due date increased by the recurrence period
- Same memo and recurrence settings

## Payment Memos

Users can now add payment memos to invoices for better tracking and record-keeping. Memos are
UTF-8 strings limited to 100 characters.

## Security Features

- Only invoice creator can cancel
- Prevention of double payments
- Due date validation
- Automatic payment status updates
- Validation of recurrence parameters
