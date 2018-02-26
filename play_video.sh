#!/bin/bash

export DISPLAY=:0
while true
do
    # phantomjs /home/pi/load_url.js
    livestreamer hlsvariant://http://108.201.105.106:1935/live/myStream/playlist.m3u8 best --player "omxplayer -o hdmi --timeout 20" --fifo
done
