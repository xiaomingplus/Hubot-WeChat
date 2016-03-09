config = require '../src/config'
client = require '../src/httpclient'
wxApi = require '../src/wxApi'
log = require '../src/wxLog'
err = require '../src/wxError'
_ = require 'lodash'
fs = require 'fs'
{HttpCodes, WxResCodes} = require '../src/constants'
jsons = JSON.stringify

class WxBot
  constructor: ->
    @groupInfo = {}
    @groupMemberInfo = {}
    @syncKey = {}
    @myUserName = ""
    @api = wxApi
    @notifyHubotMsg = {}
    @syncCheckCounter = @api._getMsgIdFromTimeStamp()
    @maintainerName = ""
    @toNotifySick = true

  getInit: () ->
    response = @api.getInit()
    jsonBody = @_getJsonBody response
    if response.statusCode == HttpCodes.OK
      if jsonBody.BaseResponse.Ret == WxResCodes.OK && jsonBody.Count > 0
        @syncKey = jsonBody.SyncKey
        @myUserName = jsonBody.User.UserName
        @addToGroupInfo member for member in jsonBody.ContactList when @_isGroup member
        return
    @_logResponseError(response)
    throw new Error "Failed in WxBot getInit"

  registerHubotReceiveFn: (receiveFn) ->
    @notifyHubotMsg = receiveFn

  getOplog: () ->
    response = @api.getOplog @myUserName
    jsonBody = @_getJsonBody response
    log.info "[getOplog] BaseResponse.Ret: #{jsonBody.BaseResponse.Ret}"

  updateGroupList: () ->
    response = @api.getContact()
    if response.statusCode == HttpCodes.OK
      jsonBody = @_getJsonBody response
      if jsonBody.BaseResponse.Ret == WxResCodes.OK && jsonBody.MemberCount > 0
        @addToGroupInfo member for member in jsonBody.MemberList when @_isGroup member
        return
    @_logResponseError response
    throw new Error "Failed in WxBot updateGroupList"

  updateGroupMemberList: () ->
    response = @api.getBatchContact(@groupInfo)
    if response.statusCode == HttpCodes.OK
      jsonBody = @_getJsonBody response
      if jsonBody.BaseResponse.Ret == WxResCodes.OK && jsonBody.Count > 0
        @addToGroupMemberInfo grp for grp in jsonBody.ContactList
        return
    @_logResponseError response
    throw new Error "Failed in WxBot updateGroupMemberList"

  addToGroupInfo: (member) ->
    if not @groupInfo[member.UserName]
      @groupInfo[member.UserName] = member.NickName

  addToGroupMemberInfo: (group) ->
    memberList = []
    for member in group.MemberList
      if member.DisplayName
        memberList[member.UserName] = member.DisplayName
      else
        memberList[member.UserName] = member.NickName

      @_addMaintainerUserName member.UserName, member.NickName
    @groupMemberInfo[group.UserName] = memberList

  sendMessage: (fromUser, toGroup, toUser, messageContent, callback) ->
    try
      if toGroup
        atUser = @_getAtName toGroup, toUser
        messageContent = "@#{atUser}\n#{messageContent}" if atUser
        toUserName = toGroup
      else
        toUserName = toUser if toUser
      log.debug "[wxbot:sendMessage] group: #{toGroup}, user: #{toUser}"
      log.debug "[wxbot:sendMessage] fromUser #{fromUser}, toUserName #{toUserName}"
      log.debug "[wxbot:sendMessage] messageContent: #{messageContent}"
      @api.sendMessage fromUser, toUserName, messageContent, callback
    catch error
      log.error error

  sendSyncMessage: (fromUser, toGroup, toUser, messageContent) ->
    try
      if toGroup
        atUser = @_getAtName toGroup, toUser
        messageContent = "@#{atUser}\n#{messageContent}" if atUser
        toUserName = toGroup
      else
        toUserName = toUser if toUser
      log.debug "[wxbot:sendSyncMessage] group: #{toGroup}, user: #{toUser}"
      log.debug "[wxbot:sendSyncMessage] fromUser #{fromUser}, toUserName #{toUserName}"
      log.debug "[wxbot:sendSyncMessage] messageContent: #{messageContent}"
      res = @api.sendSyncMessage fromUser, toUserName, messageContent
      log.debug "[wxbot:sendSyncMessage] Response: ", res
    catch error
      log.error error

  webWxSync: (callback) =>
    log.debug "webWxSync running in #{config.webWxSyncInterval} ms"
    try
      response = @api.webWxSync @syncKey
      jsonBody = @_getJsonBody response
      if response.statusCode == HttpCodes.OK && jsonBody.BaseResponse.Ret == WxResCodes.OK
        @syncKey = jsonBody.SyncKey ## TODO: check whether syncKey is changed when receiving new msg
        if jsonBody.AddMsgCount != 0
          log.debug "incoming message count: #{jsonBody.AddMsgList.length}"
          @_handleMessage message for message in jsonBody.AddMsgList
        if jsonBody.ModContactCount != 0
          log.debug "new mod contact count: #{jsonBody.ModContactList.length}"
          log.debug "new mod contact: %j", jsonBody.ModContactList
          @_handleModContactList contact for contact in jsonBody.ModContactList
      else
        @_logResponseError(response)
        debugMessage = "Hubot is running in issue: webWxSync error"
        sickMessage = "I'm sick and will go to bed soon."
        @_notifySick debugMessage, sickMessage
        @_throwWxError "webWxSync error"
    catch error
      if error instanceof err.WxError
        throw error
      log.error error

  syncCheck: (callback) =>
    log.debug "syncCheck running in #{config.syncCheckInterval} ms"
    try
      @api.syncCheck @syncKey, @syncCheckCounter+1, (body, ret, e) ->
        log.debug "[syncCheck] body: #{body} ret: #{ret} error: #{e}"
        if e
          debugMessage = "Hubot is running in issue: syncCheck error: #{e}"
          sickMessage = "I'm sick and will go to bed soon."
          @_notifySick debugMessage, sickMessage
          @_throwWxError "syncCheck error"
    catch error
      if error instanceof err.WxError
        throw error
      log.error error

  reportHealthToMaintainer: (message) =>
    message = "The HUBOT is still online."
    @_notifyMaintainer message

  webWxUploadAndSendMedia: (fromUser, toUser, filePath) =>
    log.debug "To upload the file #{filePath}"
    if fs.existsSync filePath
      try
        @api.webWxUploadAndSendMedia fromUser, toUser, filePath
      catch error
        log.error error

  sendImage: (fromUser, toUser, mediaId, callback) =>
    try
      @api.sendImage fromUser, toUser, mediaId, callback
    catch error
      log.error error

  sendLatestImage: () ->
    mediaDir = config.imageDir

    if mediaDir
      # Find the latest media in dir
      fs.watch mediaDir, (event, filename) =>
        if event isnt "rename" || not filename
          return
        filePath = mediaDir + filename
        for groupName in config.sendImageGroupNameList
          log.debug "to send image to group: #{groupName}"
          toUserNameGroup = _.invert @groupInfo
          try
            @webWxUploadAndSendMedia @myUserName, toUserNameGroup[groupName], filePath
          catch error
            log.error error

  _handleMessage: (message) ->
    content = message.Content
    if @_isGroupName message.FromUserName
      re = /([@0-9a-z]+):<br\/>([\s\S]*)/
      reContent = re.exec(content)
      if reContent
        fromUserName = reContent[1]
        content = reContent[2]
      else
        fromUserName = "anonymous"
      groupUserName = message.FromUserName
      log.debug "[_handleMessage] groupUserName: #{@groupInfo[groupUserName]}, #{groupUserName}"
      log.debug "[_handleMessage] fromUser: #{@_getAtName groupUserName, fromUserName}, #{fromUserName}"
      log.debug "[_handleMessage] content: #{content}"
      groupNickName = @groupInfo[groupUserName]
      if config.listenOnAllGroups or groupNickName in config.listenGroupNameList
        @notifyHubotMsg groupUserName, fromUserName, content, null
    else
      fromUserName = message.FromUserName
      content = message.Content
      log.debug "[_handleMessage] fromUserName: #{fromUserName}"
      log.debug "[_handleMessage] content: #{content}"
      # @notifyHubotMsg null, fromUserName, content, null


  _handleModContactList: (contact) ->
    if @_isGroup contact
      @addToGroupInfo contact

      if contact.MemberCount isnt 0
        @addToGroupMemberInfo contact

  _getAtName: (groupUserName, fromUserName) ->
    groupMemberList = @groupMemberInfo[groupUserName]
    if groupMemberList
      return groupMemberList[fromUserName]
    else
      log.warning "[_getAtName] Cannot find username,
        groupUserName:#{groupUserName}
        fromUserName:#{fromUserName}"

  _isGroup: (member) ->
    member.UserName.startsWith "@@"

  _isGroupName: (name) ->
    name.startsWith "@@"

  _getJsonBody: (response) ->
    body = response.getBody 'utf-8'
    return JSON.parse body

  _logResponseError: (response) ->
    log.error "status: %s\n header: %j\n body: %j\n ",
      response.statusCode, response.headers, @_getJsonBody response

  _addMaintainerUserName: (userName, nickName) ->
    if nickName is config.maintainerName
      @maintainerName = userName

  _notifyMaintainer: (message) ->
    if @maintainerName
      @sendSyncMessage @myUserName, null, @maintainerName, message

  _notifyAllListenGroups: (message) ->
    notifyGroup = _.invert @groupInfo

    for groupName in config.listenGroupNameList
      groupUserName = notifyGroup[groupName]
      @sendSyncMessage @myUserName, groupUserName, null, message

  _notifySick: (debugMessage, sickMessage) ->
    if @toNotifySick
      @_notifyMaintainer debugMessage
      @_notifyAllListenGroups sickMessage
      @toNotifySick = false

  _throwWxError: (msg) =>
    throw new err.WxError msg if config.foreverDaemon

module.exports = WxBot