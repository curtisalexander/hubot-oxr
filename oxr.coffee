# Description
#   Converts currencies using Open Exchange Rates API
#
# Dependencies:
#   "<module name>": "<module version>"
#
# Configuration:
#   OXR_APP_ID
#
# Commands:
#   hubot exchange <amount> <base currency> to <exchange currency> - converts base currency to exchange currency
#
# Notes:
#   Adapted from https://github.com/josscrowcroft/npm-exchange-rates/blob/master/open-exchange-rates.js
#   Only performs exchanges using USD as base currency
#   Other base currencies require Enterprise or Unlimited access
#
# Author:
#   Curtis Alexander

module.exports = (robot) ->
  robot.respond /exchange (\d+|\d+\.{1}\d{2}) (\w{3}) to (\w{3})/i, (msg) ->
    oxrAmt = msg.match[1]
    oxrFrom = msg.match[2]
    oxrTo = msg.match[3]
    # Check that at least one currency is USD
    unless oxrFrom.toUpperCase() == 'USD' or oxrTo.toUpperCase() == 'USD'
      msg.send "Current version only supports exchanges involving USD"
      return
    # Check that the OXR_APP_ID is set
    unless process.env.OXR_APP_ID?
      msg.send "Please specify your Open Exchange Rates app_id in the OXR_APP_ID environment variable"
      return
    # TODO: check the 3 letter currencies exist; will require a call to http://openexchangerates.org/api/currencies.json
    # Create url string
    oxrUrl = "http://openexchangerates.org/api/latest.json?app_id=" + process.env.OXR_APP_ID
    # API call - JSON returned
    robot.http(oxrUrl)
      .get() (err, res, body) ->
        data = null
        try
          data = JSON.parse(body)
          # One currency is not USD + said currency exists
          if oxrFrom.toUpperCase() == 'USD'
            currency = oxrTo.toUpperCase()
            exchangeAmt = oxrAmt * data.rates[currency]
          else if oxrFrom.toUpperCase() != 'USD'
            currency = oxrFrom.toUpperCase()
            exchangeAmt = oxrAmt / data.rates[currency]
          # TODO: pad appropriately for the two lines
          msg.send "#{oxrAmt} #{oxrFrom.toUpperCase()} = #{exchangeAmt} #{oxrTo.toUpperCase()}\n
   1 USD = #{data.rates[currency]} #{currency}"
        catch error
          msg.send "Ran into an error parsing JSON"
          return
