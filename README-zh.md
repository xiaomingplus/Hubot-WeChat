# Hubot-Weixin
* 适配微信，集成Hubot
* 目标
  - 一次登录，任何地方/时间/场合运行。
  - 让Hubot给微信的用户提供方便与快捷的服务。
  - 与公众号不一样。公众号的缺点: 不在微信起群当中，任何与公众号的互动，其他人看不见。
    Hubot是一个具有真实微信号的机器人，其中的一大功能就是娱乐大众。独乐乐不如众乐乐。

## 功能简介 ##
* 微信网页版的基本功能
  - 自动回复到微信群
  - 可以回复多媒体信息(图片，动图，音乐)到微信群
  - 自动回复某微信联系人(目前功能被注释了。需手动打开。后续会跟进代码的更改。)
* 自动发送Hubot在线状态给维护者的微信
* 提供了foreverjs的起停脚本，方便监控Hubot的进程运行状态以及出问题的自动重启。
* 提供了一系列的后端运行脚本
  - 集成 jenkins
  - 集成图灵机器人 [turing robot](http://www.tuling123.com/)
  - 一系列的百度api商店的查询接口集成

## 配置 与 启动 ##

### 基本配置 ###

#### 前提工作 ####
* 首先，你需要给机器人注册一个微信号。当然用你自己的也可以。
* 手机端：Hubot的微信要加到微信群里面。这样Hubot会监听群的信息，自动回复。
* 手机端：Hubot的微信要添加该微信群或联系人到你的联系人列表。

### config.yaml ###
* Hubot-weixin适配器提供了一个config.yaml文件，用来配置你的适配器，大部分配置项用于启动时登录所用。
* 众所周知，目前微信网页版的登录是通过扫描二维码的方式。目前这部分工作需要用户手工来做。
  1. 用chrome或者firefox的调试模式，扫描微信的二维码登录网页版一次。
  2. 在调试模式下，从**webwxinit api** 抓取以下数据
    - header
      + cookie
    - BaseRequest
      + Uin
      + Sid
      + Skey
      + DeviceId
  3. 抓取到的数据填到config.yaml对应的配置项。
  4. **注意**： 配置项里面有以下baseUrl的配置。你要根据Hubot登录的最终Url来配置。
     因为微信的服务器对登录的微信号有分流。目前主要在wx或wx2上。
    - https://wx.qq.com/cgi-bin/mmwebwx-bin
    - https://wx2.qq.com/cgi-bin/mmwebwx-bin

* maintainerName
  - 该配置项用于配置运维Hubot的维护者的微信名称。该维护者必须要在Hubot的微信的联系人当中（手机端操作）。
  - 配置ok后。Hubot会按照config.yaml中reportHealthInterval配置项设置的时间，定时上报在线状态给维护者。

* webWxSyncInterval
  - 该配置项用于定时去微信服务器获取Hubot微信所收到的微信。
  - 默认值: 1500 毫秒，1.5秒 

* syncCheckInterval
  - 该配置项用于配置定时发送心跳信息到微信服务器
  - 默认值: 为了和目前微信网页版的行为保持一致，设置为30秒

* listenOnAllGroups
  - 默认值: true. Hubot会监听所有在它的联系人列表里面的微信群。
  - 配置为false时，Hubot会按照配置项listenGroupNameList列表里面的微信群的名称进行监听与自动回复。

* listenGroupNameList
  - 该配置项用于Hubot只监听某些微信群。

* 其他配置项：暂时不累赘多说。应该知其名知其意的。细节可以看代码。

### 启动 ###

#### 通过 npm 安装 hubot-weixin 并启动Hubot ####
* 首先，你肯定是要有hubot的(这个不在该文档说明了。请参考[Hubot官网](https://hubot.github.com))
* 把`hubot-weixin`作为依赖加到hubot的package.json
* 在你的Hubot的目录下，运行 `npm install`
* 启动hubot: `bin/hubot -a weixin`

#### 通过 npm link 安装 hubot-weixin 并启动Hubot ####
* 从当前github下载hubot-weixin的源码到指定目录
* 在Hubot的node_modules的目录下创建软链接到你的hubot-weixin目录 `npm link <your hubot-weixin dir>`
* 启动hubot: `bin/hubot -a weixin`

## 设计 & 实现 ##
* 遇到的问题
  - 微信二维码扫描登录
  - 没有微信官方的api的说明文档

* 登录的解决方案
  - 手动用Hubot的微信号登录一次微信的网页版，并抓取所需要的信息：比如cookie，Uin, Sid，SKey
  - 把抓取的信息配置到config.yaml
  - Hubot启动后，Hubot登录的网页版可以直接关掉(关窗口，非logout)。Hubot会定时发心跳给微信服务器，
    微信服务器会认为Hubot一直在登录网页版的。

* 如何解决问题
  - 用chrome/firefox的调试模式，分析微信网页版的api调用
  - 在终端中尝试用curl去试用微信网页版的api
  - 分析微信api中各个参数的含义与用法
  - 分析网页版的wxApp.js

* **注意事项(必看)**:
  - **Hubot在手机端的微信app最好在线，原因：微信服务器确认的网页版登录后，通过心跳检查Hubot是否一直在网页版**
  - **但是微信服务器大概过了两三天后，还会检查网页版和手机端app的一致性。如果手机端不在线，但网页版却一直在线，微信是不让用网页版的，但你的手机端重新登录后，Hubot还是马上能用，并收到信息的。**

## 微信适配器的软件层次与架构 ##
* 请参考[README](https://github.com/KasperDeng/Hubot-WeChat/blob/master/README.md)吧，呵呵

## 开发环境 ##
* [Getting Started With Hubot](https://hubot.github.com/docs/) on Windows/Unix-Like
* Backlog 管理
  - [kanbanflow](https://kanbanflow.com/board/23ec47145de7783b8cf2e80187538b5b)
* 版本控制
  - git 
* IDE
  - Sublime
  - or WebStorm/Vim
* 开发环境
  - Nodejs 和 npm
  - `npm install` 获取所有依赖的node模块.
    + 墙内的话，请添加选项 `--registry=https://registry.npm.taobao.org`
* 编程语言
  - coffeeScript
  - coffeelint 检查coffeescript代码的风格和bugs 

## 如何编写Hubot后端脚本 ##
* 请参考本repo的script目录的脚本
* Hubot后端脚本中的 `msg` 提供了http异步获取api数据的功能的

## 如何测Hubot后端脚本 ##
* 可以通过SHELL adapter先尝试功能，再集成到Hubot

## 贡献者 ##
* bumblebee team 
  - [Jeff Zhu](https://github.com/kfchu)
  - [Yinsong Ma](https://github.com/eyinsma)
  - [Kasper Deng](https://github.com/kasperdeng)

* [Shouxi Huang](https://github.com/hsx1612727380)

## TODO ##
* 目前并没有太多新的功能和需求。主要集中在后端脚本的开发与idea的收集。
* 单元测试

## 参考文献 ##
* [Hubot Official](https://hubot.github.com)
* [About WxChat Web API](https://github.com/hexcola/wxplugin/blob/master/protocal_2.md)
* [How to write your adapter?](https://hubot.github.com/docs/adapters/development/)

## 版权信息 ##
* [LICENSE](https://github.com/KasperDeng/Hubot-WeChat/blob/master/LICENSE)

