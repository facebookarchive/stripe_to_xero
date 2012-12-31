This is a script for porting all the Stripe data you care about into Xero as a bank statement, which means you can easily reconcile invoices, bank transfers, fees, etc. The script pulls directly from your Stripe account, with no messy intermediate steps.

# Usage

- Either `bundle install` or `gem install stripe` to use the `Stripe` gem.
- Enter your stripe secret key either as an environment variable, or copy and paste it directly into the script and uncomment the line where that happens.
- Run the script `./stripe_to_xero.rb`
- Create a "Stripe" bank account on Xero, with manual bank feeds.
- Upload `xero.csv` into "Stripe" bank account.
- Reconcile away.

# Notes

Requires ruby 1.9.

This script doesn't really deal with refunds, and we only care about transfers which are final, not ones which are pending. Happy to take pull requests to deal with refunds better.

The bank name (default: `US Bank`) is configurable by changing the `bank_name` variable at the top of the script.

# Future versions

Might include the ability to upload to Xero directly, if I can figure out some way for them to let bots in. They don't support bank account transactions entered via the API, so I'd have to fake it somehow. Might use testacular, but you know, whatevs.
>>>>>>> Update to pull directly from Stripe. No more manual labor.
