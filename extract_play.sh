#!/bin/bash

export DISPLAY=:0
eritv_url=$( ( python /home/pi/extract_url.py ) 2>&1 ) &> /dev/null
# http://108.201.105.106:1935/live/myStream/playlist.m3u8
livestreamer hlsvariant://${eritv_url}/live/myStream/playlist.m3u8 best --player "omxplayer -o hdmi --timeout 20 -b" --fifo
