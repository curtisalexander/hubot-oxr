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
#
# Author:
#   Curtis Alexander

# Set App ID (required):
module.exports = (robot) ->
  robot.respond /exchange (\d+|\d+\.{1}[\d]{2}) (gbp) to (usd)/i, (msg) ->
    # Assign variables based on the regex matching
    amt = msg.match[1]
    from = msg.match[2]
    to = msg.match[3]
    # Check that the OXR_APP_ID is set
    unless process.env.OXR_APP_ID?
      msg.send "Please specify your Open Exchange Rates app_id in the OXR_APP_ID environment variable"
    # Create url string
    oxr_url = "http://openexchangerates.org/api/latest.json?app_id=" + process.env.OXR_APP_ID
    # API call - JSON returned
    robot.http(oxr_url)
      .get() (err, res, body) ->


        data = null
        try
          data = JSON.parse(body)
          msg.send " amt: #{amt}\n
        from: #{from}\n
        to: #{to}\n
        base: #{data.base}\n
        gbp: #{data.rates['GBP']}"
        catch error
          msg.send "Ran into an error parsing JSON"
          return
