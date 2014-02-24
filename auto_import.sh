#!/bin/bash

ruby stripe_to_xero.rb
ruby mechanize.rb
rm xero.csv
echo "successfully imported stripe to xero"
