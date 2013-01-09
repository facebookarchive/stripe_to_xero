casper = require("casper").create()
system = require "system"
xeroUser = system.env.XERO_USER
xeroPass = system.env.XERO_PASSWORD
xeroStripeAcct = system.env.XERO_ACCT_ID

casper.start 'https://login.xero.com', ->
  @fill 'form#LoginForm', {userName: xeroUser, password: xeroPass}, true

casper.then ->
  @echo @getCurrentUrl()

casper.then ->
  @open "https://go.xero.com/Bank/Import.aspx?accountID=#{xeroStripeAcct}"

casper.then ->
  @echo @getCurrentUrl()
  @fill 'form#frmMain', {UploadFile: "xero.csv"}
  @click "button"
  @echo "done"

casper.run ->
  @exit()