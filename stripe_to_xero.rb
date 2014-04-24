#!/usr/bin/env ruby

require 'csv'
require 'date'
require 'stripe'

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

Stripe.api_key = ENV['STRIPE_SECRET']
#Stripe.api_key = '' #Put your secret here and comment the line above if you're not sure about env vars.
bank_name = ENV['BANK_NAME'] || "US Bank"
count = ENV['STX_COUNT'] || 50
output_file = 'xero.csv'

puts "gathering last #{count} charges"
charges = Stripe::Charge.all(count: count, :expand => ['data.customer'])
puts "done!"
puts "gathering last #{count} transfers"
transfers = Stripe::Transfer.all(count: count)
puts "done"

puts "Writing xero.csv"
CSV.open(output_file, 'wb', row_sep: "\r\n") do |csv|
  csv << ['Transaction Date','Description', 'Transaction Amount', 'Reference', 'Transaction Type', 'Payee']
  transfers.each do |transfer|
    if transfer.status == "paid"
      date = xero_date transfer.date
      description = "Transfer from Stripe"
      amount = -(cents_to_dollars transfer.amount)
      reference = transfer.id
      type = "Transfer"
      payee = bank_name
      if(defined? transfer.summary.charge_fees)
        fees = -(cents_to_dollars(transfer.summary.charge_fees))
      end
      description2 = "Stripe fees"
      type2 = "Debit"
      payee2 = "Stripe"

      csv << [date,description,amount,reference,type,payee]
      csv << [date,description2,fees,reference,type2,payee2]
    end
  end
  charges.each do |charge|
    if charge.paid
      date = xero_date charge.created
      if charge.customer
        if charge.customer.respond_to? :deleted
          description = "Payment from deleted customer id: #{charge.customer.id}"
        else
          description = "Payment from #{charge.customer.description || charge.customer.email}"
        end
      else
        description = "Payment from nil customer"
      end

      amount = cents_to_dollars charge.amount
      reference = charge.id
      type = "Credit"
      payee = ""

      if charge.customer.respond_to? :email
        payee = charge.customer.email
      else
        payee = charge.card.name
      end

      csv << [date,description,amount,reference,type,payee]
    end
    if charge.respond_to? :refunds
      charge.refunds.each do |refund|
        date = xero_date refund.created
        description = "refund for #{charge.customer.description || charge.customer.email}"
        amount = -(cents_to_dollars refund.amount)
        reference = refund.balance_transaction
        type = "Debit"
        #payee = payee from above
        csv << [date, description, amount, reference, type, payee]
      end
    elsif charge.refunded
      date = xero_date charge.created
      if charge.customer
        if charge.customer.respond_to? :deleted
          description = "Refund from deleted customer id: #{charge.customer.id}"
        else
          description = "Refund from #{charge.customer.description || charge.customer.email}"
        end
      else
        description = "Payment from nil customer"
      end

      amount = cents_to_dollars charge.amount_refunded
      reference = charge.id
      type = "Debit"
      payee = ""

      if charge.customer.respond_to? :email
        payee = charge.customer.email
      else
        payee = charge.card.name
      end

      csv << [date,description,amount,reference,type,payee]
    end
  end
end
puts "complete!"
#puts "complete! Oldest charge: #{DateTime.strptime(charges.last.created.to_s,'%s')}"
