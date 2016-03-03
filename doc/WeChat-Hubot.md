title: WeChat Hubot
author:
   name: Kasper Deng
   url: http://kasperdeng.github.io
theme: reveal-cleaver-theme
output: WeChat-Hubot.html

--

# WeChat HUBOT #

![hubot](hubot_body_big.png)

--

## What is hubot ##

Hubot is your company's robot. Install him in your company to dramatically improve employee efficiency. 

Hubot knew how to deploy the site, automate a lot of tasks, and be a source of fun in the company.

--

## ChatOps Vs. DevOpts

* [chatops-devops-with-hubot](http://blog.flowdock.com/2014/11/11/chatops-devops-with-hubot/)

--

## The role of Hubot ##

* Hubot can be treated as an employee and helps us monitor Jenkins daily work. 
* The goal is to use our common IM tools - WeChat, and not a "公众号"

--

## The main contribution -- the WeChat adapter ##

* SDE
* Problems 
* Hubot Configuration
* Adapter Software Hierachy
* Adapter integrates to Hubot

--

### SDE ###

- [Getting Started With Hubot](https://hubot.github.com/docs/) on Windows/Unix-Like
- Backlog management
  + [kanbanflow](https://kanbanflow.com/board/23ec47145de7783b8cf2e80187538b5b)
- Version control
  + git 
- IDE
  + Sublime
  + or WebStorm/Vim
- DevEnv
  - Nodejs and npm
- Programming Language
  + coffeeScript
  + coffeelint to checkstyle 

--

### The design and implementation ###

* The problem
  - Scanning the QR code to login web wechat
  - No published official WeChat api interface
* Workaround for login
  - Need login manually by scanning the QR code once
  - Capture all the required data as hubot configuration(details in next slide) 
* Shoot the trouble
  - Use chrome/firefox to analyze web WeChat API
  - Try its web APIs by curl
  - Analyze the associated parameters and its meaning
  - Analyze the wxApp.js

--

### Hubot Configuration ###

* Design Hubot can be login once and run anywhere, anytime 
* url
  - baseUrl -- wx/wx2
  - Wechat server has traffic distribution to WX/WX2 server
    dependent on hubot's WeChat ID
* Below data are required, capture them during manual login in browser 
  and config to config.yaml
  - header
    + cookie
  - BaseRequest
    + Uin
    + Sid
    + Skey
    + DeviceId

--

### Hubot Configuration ###

* webWxSyncInterval
  - To sync receiving message from WX server
  - Default: 1500 ms 
* syncCheckInterval
  - It is the heartbeat to WX server 
  - To trick WX server the login persion still on the web wechat
  - Default: 30s, it is same behavior in web wechat
* listenGroupNameList
  - It is used to control hubot only listen on some group for auto reply 

--

### The Adapter Software Hierachy ###

* Operations in our Wechat-Hubot
  - wxbot.coffee
	
* The coffeescript version's WxChat Web APIs
  - wxApi.coffee

* The http layer, including sync and async
  - httpclient.coffee

--

### Integrate Adapter to Hubot ###

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
--

### Integrate Adapter to Hubot ###

* Implement a callback to call hubot's receive method to get the incoming message
	
--

## How to write Your Scripts? ##

* Please refer to the scirpts in the repo
* Follow the coding style
* The `msg` in the scripts provides the http asycn function to get your data from open APIs

--

## Test Your Script ##

* With shell adapter
* Use your WeChat ID to test

--

## Reference ##

* [Hubot Official](https://hubot.github.com)
* [About WxChat Web API](https://github.com/hexcola/wxplugin/blob/master/protocal_2.md)
* [How to write your adapter?](https://hubot.github.com/docs/adapters/development/)

--

## Acknowledge ##

bumblebee team: Jeff Zhu, YinsongMa, Kasper Deng
and Shouxi Huang

--

