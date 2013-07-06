#!/usr/bin/env ruby

require 'csv'
require 'stripe'

Stripe.api_key = ENV['STRIPE_SECRET']
#Stripe.api_key = '' #Put your secret here and comment the line above if you're not sure about env vars.
bank_name = "US Bank"

charges = Stripe::Charge.all(count: 50)
transfers = Stripe::Transfer.all(count: 50)

def cents_to_dollars(value)
  if value != 0
    val = value.to_s[0..-3] + "." + value.to_s[-2..-1]
    val.to_f
  else
    value
  end
end

def xero_date(date_obj)
  if !date_obj.respond_to? :year
    date_obj = Time.at date_obj
  end
  date = "#{date_obj.year}-#{"%02d" % date_obj.month}-#{"%02d" % date_obj.day}"
end

CSV.open('xero.csv', 'wb', row_sep: "\r\n") do |csv|
  csv << ['Transaction Date','Description', 'Transaction Amount', 'Reference', 'Transaction Type', 'Payee']
  transfers.each do |transfer|
    if transfer.status == "paid"
    
      date = xero_date transfer.date
      description = "Transfer from Stripe"
      amount = -(cents_to_dollars transfer.amount)
      reference = transfer.id
      type = "Transfer"
      payee = bank_name
      fees = -(cents_to_dollars transfer.summary.charge_fees)
      description2 = "Stripe fees"
      type2 = "Debit"
      payee2 = "Stripe"
      
      csv << [date,description,amount,reference,type,payee]
      csv << [date,description2,fees,reference,type2,payee2]
    end
  end
  charges.each do |charge|
    if charge.paid && !charge.refunded
      date = xero_date charge.created
      description = "Payment from #{charge.customer}"
      amount = cents_to_dollars charge.amount
      reference = charge.id
      type = "Credit"
      payee = Stripe::Customer.retrieve(charge.customer).email
      
      csv << [date,description,amount,reference,type,payee]
    end
  end
  p transfers.first
  p charges.first

  # CSV.foreach 'payments.csv', headers: true do |row|
  #   if row[" Status"] == "Paid"
  #     csv << [row[" Time"].gsub(/\ \d\d:\d\d/,''), "Payment from #{row[" Customer email"]}", row[" Amount"], row['Id'], 'Credit', row[' Customer email']]
  #   end
  # end
end