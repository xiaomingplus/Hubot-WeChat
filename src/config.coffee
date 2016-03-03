yaml = require '../node_modules/js-yaml/lib/js-yaml.js'
fs   = require 'fs'
config = fs.readFileSync './node_modules/hubot-ece/config.yaml' , 'utf8'
module.exports = yaml.load config