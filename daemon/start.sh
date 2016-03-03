#!/bin/tcsh

# Prepare the env variables
setenv HUBOT_LOG_LEVEL 'debug'
setenv HUBOT_JENKINS_URL ''
setenv HUBOT_JENKINS_AUTH ''

setenv PATH /home/kasper/node-v4.2.2-linux-x64/bin:$PATH

# Start Hubot milo
#bin/hubot -a milo | tee -a ./milo-wechat.log &
bin/hubot -a milo >> ./milo-wechat.log &

