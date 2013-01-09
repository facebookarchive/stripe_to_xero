#!/bin/bash

export STRIPE_SECRET=""
export XERO_USER=""
export XERO_PASSWORD=""
export XERO_ACCT_ID=""

ruby stripe_to_xero.rb
casperjs casper.coffee