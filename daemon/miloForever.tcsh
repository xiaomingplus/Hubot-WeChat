#!/bin/tcsh

set HOME = ''
set NODE_PATH = ''

setenv HUBOT_LOG_LEVEL 'debug'
setenv HUBOT_JENKINS_URL ''
setenv HUBOT_JENKINS_AUTH ''

setenv PATH /home/kasper/node-v4.2.2-linux-x64/bin:$PATH

switch ($1)
  case "start": 
  case "stop":
  case "restart":
    echo "Going to $1 wechat-hubot milo"
    $NODE_PATH/bin/forever $1 \
      --minUptime 10000 \
      --spinSleepTime 20000 \
      --pidFile $HOME/milo-wechat.pid \
      --append \
      --verbose \
      -m 10 \
      -l $HOME/milo-wechat.log \
      -o $HOME/milo-out.log \
      -e $HOME/milo-error.log \
      -c $NODE_PATH/bin/coffee node_modules/.bin/hubot --adapter ece --name milo
    echo "The $1 operation is done"
    breaksw
  default:
    echo "Usage: miloForever.tcsh {start | stop | restart}"
endsw

