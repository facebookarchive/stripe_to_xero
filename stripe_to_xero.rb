#!/usr/bin/env ruby

require 'csv'
require 'date'
require 'stripe'
require 'optparse'

Stripe.api_key = ENV['STRIPE_SECRET']
#Stripe.api_key = '' #Put your secret here and comment the line above if you're not sure about env vars.
bank_name = ENV['BANK_NAME'] || "US Bank"
count = ENV['STX_COUNT'].to_i || 50
output_file = 'xero.csv'
maxRecordsPerRequest = 100 #Max API allows

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: stripe_to_xero.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-d [DATE]", "--date [DATE]", "Get all transfers and charges since the given date") do |dateRaw|

    date = Date.parse(dateRaw);
    time = Time.gm(date.year.to_i,date.month.to_i,date.day.to_i,0,0,0)

    options[:from_date]  = time
  end

  opts.on("-l [LIMIT]", "--limit [LIMIT]", "Limit the amount of results returned") do |limit|
      count = limit.to_i
  end

end.parse!



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

def writeChargeToCSV(charge)

  date = xero_date charge.created
  if charge.customer
    if charge.customer.respond_to? :deleted
      description = "Payment from deleted customer id: #{charge.customer.id}"
    else
      description = "Payment from #{charge.customer.description || charge.customer.email}"
    end
  else
    if charge.card.name
      description = "Payment from #{charge.card.name}"
    else
      description = "Payment from nil customer"
    end
  end
  amount = cents_to_dollars charge.amount - charge.amount_refunded
  reference = charge.id
  type = "Credit"
  
  if charge.customer.respond_to? :email
    payee = charge.customer.email
  else
    payee = charge.card.name
  end

  return [date,description,amount,reference,type,payee]


end 

def writeTransferToCSV(transfer) 

  date = xero_date transfer.date
  description = "Transfer from Stripe"
  amount = -(cents_to_dollars transfer.amount)
  reference = transfer.id
  type = "Transfer"
  payee = $bank_name
 
  return [date,description,amount,reference,type,payee]

end

def writeTransferChargeToCSV(transfer) 
  
  date = xero_date transfer.date
  reference = transfer.id
  description = "Stripe fees"
  type = "Debit"
  payee = "Stripe"

  if(defined? transfer.fee)
    fees = -(cents_to_dollars(transfer.fee))
  elsif(defined? transfer.summary.charge_fees)
    fees = -(cents_to_dollars(transfer.summary.charge_fees))
  end

  return [date,description,fees,reference,type,payee]

end

puts "Writing xero.csv"
CSV.open(output_file, 'wb', row_sep: "\r\n") do |csv|
  csv << ['Transaction Date','Description', 'Transaction Amount', 'Reference', 'Transaction Type', 'Payee']
  
  offset = 0
  retrievedRecords = 0

  begin

    if(options[:from_date])
      count = maxRecordsPerRequest
      charges = Stripe::Charge.all(
        count: count,
        offset: offset, 
        created: {gte:options[:from_date].to_i},
        :expand => ['data.customer']
      )
      totalRecordsToFetch = charges.count
    else
      charges = Stripe::Charge.all(
        count: count,
        offset: offset, 
        :expand => ['data.customer']
      )
      totalRecordsToFetch = count
    end
    
    offset += count
    retrievedRecords += count
    
    charges.each do |charge|

      if charge.paid && !charge.refunded
        csv << writeChargeToCSV(charge)
      end 

    end

  end while totalRecordsToFetch > retrievedRecords 

  offset = 0
  retrievedRecords = 0

  begin

    if(options[:from_date])
      count = maxRecordsPerRequest
      transfers = Stripe::Transfer.all(
        count: count,
        offset: offset, 
        date: {gte: options[:from_date].to_i}
      )
      totalRecordsToFetch = transfers.count
    else
      transfers = Stripe::Transfer.all(
        count: count,
        offset: offset
      )
      totalRecordsToFetch = count
    end

    offset += count
    retrievedRecords += count
  
    transfers.each do |transfer|
      if transfer.status == "paid"
        csv << writeTransferToCSV(transfer)
        csv << writeTransferChargeToCSV(transfer)
      end
    end

  end while totalRecordsToFetch > retrievedRecords 
  
end
puts "complete!"
# puts "complete! Oldest charge: #{DateTime.strptime(charges.last.created.to_s,'%s')}"
