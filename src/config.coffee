yaml = require 'js-yaml'
fs   = require 'fs'
config = fs.readFileSync './node_modules/hubot-weixin/config.yaml' , 'utf8'
module.exports = yaml.load config