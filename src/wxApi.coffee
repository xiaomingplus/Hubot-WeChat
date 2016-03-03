config = require '../src/config'
client = require '../src/httpclient'
log = require '../src/wxLog'
{HttpCodes, WxResCodes} = require '../src/constants'
jsons = JSON.stringify
path = require 'path'
fs = require 'fs'
util = require 'util'

getContact = (callback = null) ->
  url = config.baseUrl + config.getContactUrl
  if callback
    params = {} # For extension
    res = client.get url, params, callback
  else
    res = client.get_sync url
    return res

getBatchContact = (groupInfo, callback = null) ->
  url = config.baseUrl + config.batchGetContactUrl
  groupList = []
  for key of groupInfo
    groupList.push({"UserName": key, "ChatRoomId": ""})
  params =
    "BaseRequest": _getBaseRequest()
    "Count": groupList.length
    "List": groupList
  if callback
    client.post {url:url}, params, callback
  else
    res = client.post_sync url, params
    return res

sendMessage = (fromUser, toUser, messageContent, callback) ->
  url = config.baseUrl + config.sendMsgUrl
  msgId = _getMsgIdFromTimeStamp()
  m =
    Type: 1
    Content: messageContent
    FromUserName: fromUser
    ToUserName: toUser
    LocalID: msgId
    ClientMsgId: msgId
  params =
    "BaseRequest": _getBaseRequest()
    "Msg": m
  client.post {url:url}, params, callback

sendSyncMessage = (fromUser, toUser, messageContent) ->
  url = config.baseUrl + config.sendMsgUrl
  msgId = _getMsgIdFromTimeStamp()
  m =
    Type: 1
    Content: messageContent
    FromUserName: fromUser
    ToUserName: toUser
    LocalID: msgId
    ClientMsgId: msgId
  params =
    "BaseRequest": _getBaseRequest()
    "Msg": m
  res = client.post_sync url, params
  return res

getInit = (callback = null) ->
  url = config.baseUrl + config.getWebwxInit
  params =
    "BaseRequest": _getBaseRequest()
  if callback
    client.post {url:url}, params, callback
  else
    res = client.post_sync url, params
    return res

getOplog = (myUserName, callback = null) ->
  url = config.baseUrl + config.getWebwxOplog
  params =
    "BaseRequest": _getBaseRequest()
    "CmdId": 2
    "RemarkName": config.onlineRemarkName
    "UserName": myUserName
  log.info "params #{params}", params
  if callback
    client.post {url:url}, params, callback
  else
    res = client.post_sync url, params
    return res

webWxSync = (synckey, callback) ->
  url = config.baseUrl + config.getWebwxSync
  params =
    "BaseRequest": _getBaseRequest()
    "SyncKey": synckey
    "rr": -602451563 ## Todo: what is rr?
  res = client.post_sync url, params
  return res

syncCheck = (synckey, syncCheckCounter, callback) ->
  url = config.baseUrl + config.syncCheck
  params =
    "r": _getMsgIdFromTimeStamp() ## Todo: what is r?
    "skey": config.Skey
    "sid": config.Sid
    "uin": config.Uin
    "deviceid": config.DeviceID
    "syncKey": synckey
    "_": syncCheckCounter

  res = client.get url, params, callback
  return res

webWxUploadAndSendMedia = (fromUser, toUser, filePath) ->
  url = config.baseUploadUrl + config.webWxUploadMedia + "?f=json"
  newLine = "\r\n"
  new2Lines = "\r\n\r\n"
  boundaryInContentType = "----WebKitFormBoundaryacBe9jJZzIeqONeW" # + Math.random().toString(16)
  boundary = "--#{boundaryInContentType}"
  boundaryKey = "#{boundary}#{newLine}"
  endBoundary = "\r\n\r\n--#{boundaryInContentType}--\r\n"

  UPLOAD_MEDIA_TYPE_ATTACHMENT = 4

  file = fs.openSync filePath, 'r'
  stats = fs.statSync filePath
  fileName = path.basename filePath
  ext = (fileName.split ".")[1]

  wuFileType = 
    "jpg":  "WU_FILE_0"
    "jpeg": "WU_FILE_0"
    "png":  "WU_FILE_0"
    "gif":  "WU_FILE_3"

  mediaType =
    "jpg":  "image/jpeg"
    "jpeg": "image/jpeg"
    "png":  "image/png"
    "gif":  "image/gif"

  mediaT = 
    "jpg":  "pic"
    "jpeg": "pic"
    "png":  "pic"
    "gif":  "doc"

  log.debug "stats: %j", stats

  content = boundaryKey
  content = "Content-Disposition: form-data; name=\"id\"#{new2Lines}"
  content += "#{wuFileType[ext]}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"name\"#{new2Lines}"
  content += "#{fileName}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"type\"#{new2Lines}"
  content += "#{mediaType[ext]}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"lastModifiedDate\"#{new2Lines}"
  content += "#{stats.mtime}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"size\"#{new2Lines}"
  content += "#{stats.size}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"mediatype\"#{new2Lines}"
  #content += "#{file.ext? "pic" then "doc"}#{newLine}"
  content += "#{mediaT[ext]}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"uploadmediarequest\"#{new2Lines}"
  uploadmediarequest =
    "BaseRequest": _getBaseRequest()
    "ClientMediaId": +new Date
    "TotalLen": stats.size,
    "StartPos": 0,
    "DataLen": stats.size,
    "MediaType": UPLOAD_MEDIA_TYPE_ATTACHMENT
  content += "#{jsons uploadmediarequest}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"webwx_data_ticket\"#{new2Lines}"
  cookieItems = config.cookie.split ";"
  for item in cookieItems
    ticket = (item.split "=")[1] if item.indexOf "webwx_data_ticket" isnt -1
  content += "#{ticket}#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"pass_ticket\"#{new2Lines}"
  content += "jfL17ewPjc7ArkA84QGNyxpnL7bq7ZEaUJ8x4r/MzsliajJ8F1KT4RIQB73Zn9IW#{newLine}"

  content += boundaryKey
  content += "Content-Disposition: form-data; name=\"filename\"; filename=\"#{fileName}\"#{newLine}"
  content += "Content-Type: #{mediaType[ext]}#{new2Lines}"

  log.debug "stats size: " + stats.size

  contentLength = Buffer.byteLength(content) + Buffer.byteLength(endBoundary) + stats.size

  header =
    "Accept": "*/*"
    "Accept-Encoding": "gzip, deflate"
    "Accept-Language": "en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4"
    "Content-Length": contentLength
    "Connection": config.connection
    "Content-Type": "multipart/form-data; boundary=#{boundaryInContentType}"
    # "Host": "file2.wx.qq.com"
    # "Origin": "https://wx2.qq.com"
    # "Referer": "https://wx2.qq.com/"

  options =
    "url": url
    "headers": header

  params =
    "boundary": boundary
    "endBoundary": endBoundary
    "filePath": filePath

  log.debug "upload content:\n#{content}"
  log.debug "params: %j", params

  client.upload_file options, params, content, (body) ->
    log.debug "upload file done\n", body
    try
      jsonBody = JSON.parse body
      # log.debug "jsonBody: %j", jsonBody
      if jsonBody.BaseResponse.Ret is 0
        mediaId = jsonBody.MediaId
        if ext isnt "gif"
          sendImage fromUser, toUser, mediaId, (body, ret, e) ->
              log.debug "sendImageToUser", jsons body
        else
          sendEmotion fromUser, toUser, mediaId, (body, ret, e) ->
              log.debug "sendEmotionToUser", jsons body
      else
        log.error "Upload media failed, RC: #{jsonBody.BaseResponse.Ret}"
    catch error
      log.error "Failed to parse as JSON, #{error}"

sendImage = (fromUser, toUser, mediaId, callback) ->
  log.debug "mediaId: #{mediaId}"
  url = config.baseUrl + config.webwxsendmsgimg + "?fun=async&f=json"
  # + "&pass_ticket=jfL17ewPjc7ArkA84QGNyxpnL7bq7ZEaUJ8x4r/MzsliajJ8F1KT4RIQB73Zn9IW"
  msgId = _getMsgIdFromTimeStamp()
  m =
    Type: 3
    MediaId: mediaId
    FromUserName: fromUser
    ToUserName: toUser
    LocalID: msgId
    ClientMsgId: msgId
  params =
    "BaseRequest": _getBaseRequest()
    "Msg": m
  client.post {url:url}, params, callback

sendEmotion = (fromUser, toUser, mediaId, callback) ->
  log.debug "mediaId: #{mediaId}"
  url = config.baseUrl + "/webwxsendemoticon" + "?fun=sys"
  # + "&pass_ticket=jfL17ewPjc7ArkA84QGNyxpnL7bq7ZEaUJ8x4r/MzsliajJ8F1KT4RIQB73Zn9IW"
  msgId = _getMsgIdFromTimeStamp()
  m =
    Type: 47
    EmojiFlag: 2
    MediaId: mediaId
    FromUserName: fromUser
    ToUserName: toUser
    LocalID: msgId
    ClientMsgId: msgId
  params =
    "BaseRequest": _getBaseRequest()
    "Msg": m
  client.post {url:url}, params, callback


_getBaseRequest = () ->
  return r =
    Uin: config.Uin
    Sid: config.Sid
    Skey: config.Skey
    DeviceID: config.DeviceID

_getRandom = (max, min) ->
  return Math.floor(Math.random() * (max - min)) + min

_getMsgIdFromTimeStamp = () ->
  return new Date().getTime().toString() + _getRandom 9999, 1000

module.exports = {
  getContact
  getBatchContact
  getInit
  getOplog
  webWxSync
  syncCheck
  sendMessage
  sendSyncMessage
  webWxUploadAndSendMedia
  sendImage
  _getMsgIdFromTimeStamp
}
