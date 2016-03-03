# Forever #
* [Forever Github](https://github.com/foreverjs/forever)
* [Usage](https://github.com/nodejitsu/forever#usage)
* Use forever to start hubot and current miloForever.tcsh. Need to update it to adapt to your ENV.
  - The script is TCSH. For Bash, need to create another one to adapt to BASH.
  - The HOME, NODE_PATH etc needs to update as in your actual ENV.
* Note:
  - `--minUptime` sets the minimum amount of time that an application is expected to run. If it crashes before that limit, it's considered to be "spinning" or problematic.
  - `--spinSleepTime` sets an amount of time that forever will wait before trying to restart a "spinning" application again.
