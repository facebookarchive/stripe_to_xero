#!/bin/bash

ruby stripe_to_xero.rb
casperjs casper.coffee
rm xero.csv
echo "successfully imported stripe to xero"
