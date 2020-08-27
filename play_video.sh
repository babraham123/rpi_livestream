#!/bin/bash

eritv_url="http://45.27.53.1:1935/live/myStream/playlist.m3u8"

/home/babraham/heartbeat.sh
/usr/local/bin/livestreamer hlsvariant://${eritv_url} best --player "/usr/bin/omxplayer --timeout 20" --fifo
