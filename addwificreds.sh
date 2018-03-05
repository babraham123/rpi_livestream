#!/bin/bash

echo "
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid=\"$1\"
    psk=\"$2\"
}
" >> /etc/wpa_supplicant/wpa_supplicant.conf

# stop hotspot, connect to wifi, stop signin server
/usr/bin/autohotspot
