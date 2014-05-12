#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'

mech = Mechanize.new

page = mech.get('https://login.xero.com')
form = page.forms[0]
form.userName = ENV['XERO_USER']
form.password = ENV['XERO_PASSWORD']

page = form.submit()

page = mech.get("https://go.xero.com/Bank/Import.aspx?accountID=#{ENV['XERO_ACCT_ID']}")

form = page.forms[0]
form.file_uploads.first.file_name = "xero.csv"
form.submit form.buttons.first
