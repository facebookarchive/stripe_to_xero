This is a script for porting all the Stripe data you care about into Xero as a bank statement, which means you can easily reconcile invoices, bank transfers, fees, etc. The script pulls directly from your Stripe account, with no messy intermediate steps.

# Usage

- Either `bundle install` or `gem install stripe` to use the `Stripe` gem.
- Install CasperJS if you'd like to automatically upload the results into Xero
- Enter your stripe secret key either as an environment variable, or copy and paste it directly into the script and uncomment the line where that happens.
- Enter your Xero credentials to enable auto upload
- Run the script `./stripe_to_xero.rb`
- Create a "Stripe" bank account on Xero, with manual bank feeds.
- Upload `xero.csv` into "Stripe" bank account, or use our `auto_import.sh` script to make it happen automatically.
- Reconcile away.

# Notes

We use `foreman` to easily set up environment variables. You might find it handy too.

Requires ruby 1.9.

The bank name for transfers (default: `US Bank`) is configurable by changing the `bank_name` variable at the top of the script.

# Changelog

v1 - Implements new refund calculation, adds better echoed text, uses Stripe's newish `expand` option to make 50 less API calls, and increase speed A LOT.
