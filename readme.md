This is a script for porting all the Stripe data you care about into Xero as a bank statement, which means you can easily reconcile invoices, bank transfers, fees, etc.

# Usage

- Log into Stripe's [payments page][1], and click "export" in the upper right corner.
- Head to Stripe's [transfers page][2], and again, click export in the upper right corner.
- Copy said export files into the same directory as this script.
- Run the script `./stripe_to_xero.rb`
- Upload `xero.csv` into a "Stripe" bank account.
- Reconcile away.

# Notes

This script doesn't really deal with refunds, and we only care about transfers which are final, not ones which are pending. Happy to take pull requests to deal with refunds better.

The bank is hardcoded to be "US Bank" because that's my bank. You can likely create a rule to map transfers to whatever bank account you use.

[1]: https://manage.stripe.com/payments
[2]: https://manage.stripe.com/transfers