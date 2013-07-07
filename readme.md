This is a script for porting all the Stripe data you care about into Xero as a bank statement, which means you can easily reconcile invoices, bank transfers, fees, etc. The script pulls directly from your Stripe account, with no messy intermediate steps.

# Configuration

## Configuration in Xero
Create a `Stripe` bank account in Xero. It should be a manual account. Also, create a new `bot` user, who will handle uploading bank statements.

## Environment Variables
Use these environment variables as configuration
    STRIPE_SECRET="api key from stripe"
    XERO_USER="username for xero"
    XERO_PASSWORD="password for xero"
    XERO_ACCT_ID="account id from Xero"
    BANK_NAME="the name of your transfer bank"
    STX_COUNT=50 #optional, but recommended

Be sure to `bundle install` to install the `stripe` gem. You should also install `casperjs` with `npm install -g casperjs` if you'd like to use the `auto_import.sh` script.

# Dependencies

- `stripe` gem

# Recommended tools
- `casperjs` npm module (`casper.coffee` automagically uploads the bank statement into Xero, even though Xero doesn't provide an API.)
- `foreman` (recommended for easily running the script with environment variables)

# Usage

- Run `auto_import.sh` to automatically import your Stripe data into Xero. (If you have `casperjs` installed)
- Or, just run the `stripe_to_xero.rb` script to generate `xero.csv` which you can upload manually.
- Reconcile away.

# Notes

We use `foreman` to easily set up environment variables. You might find it handy too.

Requires ruby 1.9.

# Changelog

v1 - Implements new refund calculation, adds better echoed text, uses Stripe's newish `expand` option to make 50 less API calls, and increase speed A LOT.
