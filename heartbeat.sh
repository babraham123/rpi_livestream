#!/bin/sh

/usr/bin/fping google.com
/usr/local/bin/phantomjs /home/babraham/load_url.js &
/bin/sleep 2
/usr/bin/killall phantomjs
