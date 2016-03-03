try
  {Robot, Adapter, TextMessage, User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot, Adapter, TextMessage, User} = prequire 'hubot'

WxBot = require "../src/wxbot"
config = require '../src/config'
log = require '../src/wxLog'
jsons = JSON.stringify

class WxBotAdapter extends Adapter

  constructor: (robot) ->
    super
    @robot.logger.info "Construct Robot"
    @robot = robot

  send: (envelope, strings...) ->
    @robot.logger.info "hubot is sending #{strings}"
    if envelope.hasOwnProperty "user"
      toGroup = envelope.user.room
      toUser = envelope.user.name
    else if envelope.hasOwnProperty "room" # To support robot.messageRoom
      toGroup = envelope.room

    for string in strings
      @wxbot.sendMessage @wxbot.myUserName, toGroup, toUser, string, (ret,e) ->
        log.debug "sendToUser", jsons ret

  reply: (envelope, strings...) ->
    @robot.logger.info "hubot is repling #{strings}"
    @send envelope, strings...

  emote: (envelope, strings...) ->
    if envelope.hasOwnProperty "user"
      toGroup = envelope.user.room
      toUser = envelope.user.name
    else if envelope.hasOwnProperty "room" # To support robot.messageRoom
      toGroup = envelope.room
    for string in strings
      # the string is a file path of media to be sent
      @wxbot.webWxUploadAndSendMedia @wxbot.myUserName, toGroup, string

  run: ->
    self = @
    @robot.logger.info "WxHubot Staring Running"
    @wxbot = new WxBot()
    @wxbot.getInit()
    @wxbot.updateGroupList()
    @wxbot.updateGroupMemberList()
    @wxbot.registerHubotReceiveFn @hubotReceiveMsgFn
    @emit 'connected'
    @robot.logger.info "wx robot init done"
    log.debug "@groupInfo", @wxbot.groupInfo
    log.debug "@groupMemberInfo", @wxbot.groupMemberInfo
    setInterval @wxbot.webWxSync, config.webWxSyncInterval
    setInterval @wxbot.syncCheck, config.syncCheckInterval
    setInterval @wxbot.reportHealthToMaintainer, config.reportHealthInterval
    @wxbot.sendLatestImage()

    @_quitProcessOnException()

  hubotReceiveMsgFn: (groupName, userName, content, msgId) =>
    user = new User userName, {room: groupName}
    @receive new TextMessage user, content, msgId

  _quitProcessOnException: () ->
    process.on 'uncaughtException', (err) ->
      log.critical "caught an exception, #{err}! Process exit code: 2"
      process.exit 2

exports.use = (robot) ->
  new WxBotAdapter robot