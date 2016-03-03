# Hubot-WeChat
* This is wechat adapter for hubot.
* Goal
  - login once, run anywhere, anytime
  - Make life easier and let bot do something for us in backend

## Features of Hubot-WeChat (WeChat Adapter) ##
* Basic functions as that in WeChat Web
  - Auto-reply text to group
  - Auto-reply media to group
  - Auto-reply to specific person (function is available but comment out)
* Auto-report status to maintainer
* A forever script to launch the hubot instance and mornintoring
* Aboundants of scripts for hubot
  - integrated with jenkins
  - integrated with [turing robot](http://www.tuling123.com/)
  - Lots of life information by querying the APIs provided from baidu api-store

## Wechat Adapter Configuration ##

### Basic Config ###
* The hubot needs a real WeChatID
* The hubot's WeChatID should be include in the group to be listened on for auto-reply
* The group/specific person should be save into that contact list

### config.yaml ###
* A config.yaml is provided to set the configuration items 
  - Those items most are for wechat login in Hubot-WeChat startup

* Get config items method
  - Login the wechat from browser, use the wechatId which is used for hubot
  - Capture data from webwxinit api from browser debug mode

* url
  - baseUrl -- wx/wx2
  - Wechat server has traffic distribution to WX/WX2 server dependent on hubot's WeChat ID 

* Below data are needed and set into config.yaml apporiated fields 
  - header
    + cookie
  - BaseRequest
    + Uin
    + Sid
    + Skey
    + DeviceId

* maintainerName
  - Please fill the maintainer's wechat name (the maintainer should be in hubot's wechat contact list) 
  - Hubot will report its online status to maintainer in a configured interval

* webWxSyncInterval
  - To sync receiving message from WX server
  - Default: 1500 ms 

* syncCheckInterval
  - It is the heartbeat to WX server 
  - To trick WX server the login persion still on the web wechat
  - Default: 30s, it is same behavior in web wechat

* listenOnAllGroups
  - default value: true. Then hubot will listen on all the group where it is in

* listenGroupNameList
  - It is used to control hubot only listen on some group for auto reply 

* Other config item: it's simple to know from its meaning and you can check the code for its usage

## Design & Implementation Notes ##
* The problem
  - Scanning the QR code to login web wechat
  - No published official WeChat api interface
* Workaround for login
  - Need login manually by scanning the QR code once
  - Capture all the required data as hubot configuration(details in next slide) 
* Shoot the trouble
  - Use chrome/firefox to analyze web WeChat API
  - Try its web APIs by curl
  - Analyze the parameters and what it is
  - Analyze the wxApp.js

## The Adapter Software Hierachy ##
* Operations in our Wechat-Hubot
  - wxbot.coffee
	
* The coffeescript version's WxChat Web APIs
  - wxApi.coffee

* The http layer, including sync and async
  - httpclient.coffee

## Integrate Adapter to Hubot ##
* Implement the needed methods of adapter
  - constructor
    + Getting the hubot robot 
  - send
    + hubot sends out message to specific persion/group
  - reply 
    + hubot replies message to specific persion/group
  - run
    + New a WxBot
    + Being called in hubot launching
      It is used to init the wechat groups information
    + Integrate to Hubot by calling

    ~~~
    @emit 'connected'
    ~~~
* Implement a callback to call hubot's receive method to get the incoming message
	
## How to write Your Scripts? ##
* Please refer to the scirpts in repo
* Follow the coding style
* The `msg` in the scripts provides the http asycn function to get your data from open APIs

## SDE ##
* [Getting Started With Hubot](https://hubot.github.com/docs/) on Windows/Unix-Like
* Backlog management
  - [kanbanflow](https://kanbanflow.com/board/23ec47145de7783b8cf2e80187538b5b)
* Version control
  - git 
* IDE
  - Sublime
  - or WebStorm/Vim
* DevEnv
  - Nodejs and npm
  - Use `npm install` to get all the node modules
    + Inside greatwall, add option `--registry=https://registry.npm.taobao.org`
* Programming Language
  - coffeeScript
  - coffeelint to checkstyle 

## Test Your Script ##
* With shell adapter
* Use your WeChat ID to test

## Contributor ##
* bumblebee team 
  - [Jeff Zhu](https://github.com/kfchu)
  - [Yinsong Ma](https://github.com/eyinsma)
  - [Kasper Deng](https://github.com/kasperdeng)

* [Shouxi Huang](https://github.com/hsx1612727380)

## TODO ##
* No much functions to be implemented, most are focus on scripting
* Unit test

## Reference ##
* [hubot-ece git repo](ssh://<eid>@gerritforge.lmera.ericsson.se:29418/innovation.git)
* [Hubot Official](https://hubot.github.com)
* [About WxChat Web API](https://github.com/hexcola/wxplugin/blob/master/protocal_2.md)
* [How to write your adapter?](https://hubot.github.com/docs/adapters/development/)

## License ##
* See the [LICENSE](https://github.com/github/hubot/blob/master/LICENSE.md) file for license rights and limitations (MIT).

