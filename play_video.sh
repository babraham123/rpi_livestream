#!/bin/bash

# The url may change after several months. To find the current one, load https://www.dendenmedia.com/eri-tv/ with the
# developer tools sidebar open. Under the network tab, search for "*.m3u8" and copy the url.

eritv_url="http://jmc-live.ercdn.net/eritreatv/eritreatv.m3u8"

# /home/babraham/heartbeat.sh
/usr/local/bin/streamlink hlsvariant://${eritv_url} best --player "/usr/bin/omxplayer --timeout 20" --fifo
