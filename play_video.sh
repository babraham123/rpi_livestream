#!/bin/bash

export DISPLAY=:0
eritv_url=$(python /home/pi/extract_url.py)

if [ "$eritv_url" = "NOT_FOUND" ]; then
    echo "eritv url not found"
    eritv_url="http://108.201.105.106:1935/live/myStream/playlist.m3u8"
fi

/usr/bin/phantomjs /home/pi/load_url.js || true

livestreamer hlsvariant://${eritv_url} best --player "omxplayer -o hdmi --timeout 20 -b" --fifo
