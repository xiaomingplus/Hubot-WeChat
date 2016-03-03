config = require '../src/config'
client = require '../src/httpclient'
jsons = JSON.stringify
log = new (require 'log')('debug')

sendmessage = ->
  r =
    Uin: config.Uin
    Sid: config.Sid
    Skey: config.Skey
    DeviceID: config.DeviceID
  m =
    Type: 1
    Content: "你好"
    FromUserName: "@c917024c70813d5a496131b8718e04484efc61a05a428bae07b7c8a3f330e1f5"
    ToUserName: "@@c645f7e8067eb611be40480105e38458b3be9c0875417e5b74494659b312f4fc"
    LocalID: 14482757380740999
    ClientMsgId: 14482757380740999

  params =
    "BaseRequest": r
    "Msg": m

  client.post {url:config.url} , params , (ret,e) ->
    log.debug "sendToUser", jsons ret
  
getbatchcontact = ->
  #l1 =
  # UserName: config.groupUserName1
  # ChatRoomId: config.groupChatRoomId1
  l2 =
    UserName: config.groupUserName2
    ChatRoomId: config.groupChatRoomId2
  #l3 =
  # UserName: config.groupUserName3
  # ChatRoomId: config.groupChatRoomId3

  r =
    Uin: config.groupUin
    Sid: config.groupSid
    Skey: config.groupSkey
    DeviceID: config.groupDeviceID
    
  l =
    [
  #   l1
      l2
  #   l3
    ]

  params =
    "BaseRequest": r
    "Count": 3
    "List": l

  #log.info "params", params

  client.post {url:config.groupUrl} , params , (ret,e) ->
    log.debug "getMember", jsons ret

getcontact = (callback) ->
  url = "https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxgetcontact"
  params =
    r: new Date().getTime()

  client.get url, params, (ret, e)->
    callback(ret, e)

get_group = (ret, e) ->
  memberCount = ret.MemberCount
  i = 0
  re = /@@[a-zA-Z0-9]/
  #groupmap = new Map()
  groupusernamearr = new Array()
  while i++ < memberCount
    #log.info ret.MemberList[i - 1].UserName
    if re.test(ret.MemberList[i - 1].UserName)
      log.info ret.MemberList[i - 1].UserName
      groupusernamearr[i - 1] = ret.MemberList[i - 1].UserName

getcontact(get_group)


sendmessage()
#getbatchcontact()
#getcontact()