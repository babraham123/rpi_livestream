#!/bin/bash

# The url may change after several months. To find the current one, load http://www.eastafro.com/EriTV1/ with the
# developer tools sidebar open. Under the network tab, search for "playlist.m3u8" and copy the url.

eritv_url="http://45.27.53.1:1935/live/myStream/playlist.m3u8"

/home/babraham/heartbeat.sh
/usr/local/bin/livestreamer hlsvariant://${eritv_url} best --player "/usr/bin/omxplayer --timeout 20" --fifo
