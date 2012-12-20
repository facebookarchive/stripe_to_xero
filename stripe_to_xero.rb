#!/usr/bin/env ruby

require 'csv'

CSV.open('xero.csv', 'wb', row_sep: "\r\n") do |csv|
  csv << ['Transaction Date','Description', 'Transaction Amount', 'Reference', 'Transaction Type', 'Payee']
  CSV.foreach 'transfers.csv', :headers => true do |row|
    if row[" State"] == "Paid"
      csv << [row["Date"].gsub(/( 00:00)/, ''), 'Transfer', "-" + row[' Amount'].gsub(/[\$\,]/, ''), row[' ID'], "transfer", "US Bank"]
      csv << [row["Date"].gsub(/( 00:00)/, ''), "Stripe fee", "-" + row[' Charge Fees'].gsub(/[\$\,]/, ''), row[" ID"], "Debit", "Stripe"]
    end
  end
  CSV.foreach 'payments.csv', headers: true do |row|
    if row[" Status"] == "Paid"
      csv << [row[" Time"].gsub(/\ \d\d:\d\d/,''), "Payment from #{row[" Customer email"]}", row[" Amount"], row['Id'], 'Credit', row[' Customer email']]
    end
  end
end