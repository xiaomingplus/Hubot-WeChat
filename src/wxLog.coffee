Log = require 'log'
fs = require 'fs'
config = require '../src/config'

if config.logToFile
  stream = fs.createWriteStream config.wxLogPath
else
  stream = process.stdout

log = new Log process.env.HUBOT_LOG_LEVEL or 'info', stream

module.exports = log
