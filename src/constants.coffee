
HttpCodes = Object.freeze
  OK: 200,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  SERVER_ERROR: 500

WxResCodes = Object.freeze
  OK: 0,
  ERROR1: 1,
  ERROR2: -1,
  INVALID_REQUEST1: 1100,
  INVALID_REQUEST2: 1200

module.exports =
  HttpCodes: HttpCodes
  WxResCodes: WxResCodes
