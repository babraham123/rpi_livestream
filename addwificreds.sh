#!/bin/bash

echo "
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid=\"$1\"
    psk=\"$2\"
}
" | sudo tee --append /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null

# stop hotspot, connect to wifi, stop signin server
sudo /usr/bin/autohotspot
