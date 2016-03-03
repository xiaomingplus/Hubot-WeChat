util = require 'util'

WxError = (message) ->
  this.name = 'WxError'
  this.message = message || 'Default Message'
  Error.captureStackTrace this, this

util.inherits WxError, Error
WxError.prototype = Object.create Error.prototype
WxError.prototype.constructor = WxError

module.exports = 
  WxError: WxError
