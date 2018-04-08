#!/bin/bash
# version 1.0
# derived from version 0.95-1-N/HS at the  RaspberryConnect website 
# http://www.raspberryconnect.com/network/item/331-raspberry-pi-auto-wifi-hotspot-switch-no-internet-routing

# Network Wifi & Hotspot with Internet
# A script to switch between a wifi network and an NON Internet routed Hotspot
# For use with a Raspberry Pi zero W or Zero with usb wifi dongle. 
# Also for any Raspberry Pi where an internet routed hotspot is not required.
# Works at startup or with a seperate timer or manually without a reboot
# Other setup required find out more at http://www.raspberryconnect.com

GetWifiDetails()
{
    wifidev="wlan0" #device name to use. Default is wlan0.
    #use the command: iw dev ,to see wifi interface name 

    IFSdef=$IFS
    #These four lines capture the wifi networks the RPi is setup to use
    wpassid=$(awk '/ssid="/{ print $0 }' /etc/wpa_supplicant/wpa_supplicant.conf | awk -F'ssid=' '{ print $2 }' ORS=',' | sed 's/\"/''/g' | sed 's/,$//')
    IFS=","
    ssids=($wpassid)
    IFS=$IFSdef #reset back to defaults

    #Note:If you only want to check for certain SSIDs
    #ssids=('mySSID1' 'mySSID2' 'mySSID3')

    #Enter the Routers Mac Addresses for hidden SSIDs, seperated by spaces ie 
    #( '11:22:33:44:55:66' 'aa:bb:cc:dd:ee:ff' ) 
    mac=()
    ssidsmac=("${ssids[@]}" "${mac[@]}") #combines ssid and MAC for checking
}

createAdHocNetwork()
{
    echo "Starting Hotspot"
    ip link set dev "$wifidev" down
    ip addr add 10.0.0.1/24 brd + dev "$wifidev"
    # ip address add 10.0.0.1/24 broadcast 10.0.0.255 dev "$wifidev"
    ip link set dev "$wifidev" up
    systemctl start dnsmasq
    systemctl start hostapd
    systemctl start signinserver
}

KillHotspot()
{
    echo "Shutting Down Hotspot"
    systemctl stop signinserver
    ip link set dev "$wifidev" down
    systemctl stop hostapd
    systemctl stop dnsmasq
    ip addr flush dev "$wifidev"
    ip link set dev "$wifidev" up
}

ChkWifiUp()
{
    echo "Checking WiFi connection ok"
    sleep 10 #give time for connection to be completed to router
    if wpa_cli -i "$wifidev" status | grep 'ip_address' &> /dev/null
    then # the payload, needs internet access
    echo "Starting payload"
    systemctl start eritvstream
    else #Failed to connect to wifi (check your wifi settings, password etc)
        echo 'Wifi failed to connect, falling back to Hotspot.'
        wpa_cli terminate "$wifidev" &> /dev/null
        createAdHocNetwork
    fi
}

StartWifi()
{
    echo "Bringing Wifi Up"
    wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf &> /dev/null
}

ScrubWifi()
{
    echo "Cleaning wifi files"
    wpa_cli terminate &> /dev/null
    ip addr flush "$wifidev"
    ip link set dev "$wifidev" down
    rm -r /var/run/wpa_supplicant &> /dev/null
    ip link set dev "$wifidev" up
}

NoDevice()
{
    #if no wifi device,ie usb wifi removed, activate wifi so when it is
    #reconnected wifi to a router will be available
    echo "No wifi device connected"
    StartWifi
    exit 1
}

FindSSID()
{
    #Check to see what SSID's and MAC addresses are in range
    ssidChk=('NoSSid')
    local i=0; local j=0
    until [ $i -eq 1 ] #wait for wifi if busy, usb wifi is slower.
    do
        ssidreply=$((iw dev "$wifidev" scan ap-force | egrep "^BSS|SSID:") 2>&1) &> /dev/null 
        if echo "$ssidreply" | grep "No such device (-19)" &> /dev/null; then
            NoDevice
        elif ! echo "$ssidreply" | grep "resource busy (-16)"  &> /dev/null ;then
            i=1
        elif (($j >= 5)); then #if busy 5 times goto hotspot
            ssidreply=""
            i=1
        else #see if device not busy in 2 seconds
            j=$((j = 1))
            sleep 2
        fi
    done

    for ssid in "${ssidsmac[@]}"
    do
        if (echo "$ssidreply" | grep "$ssid") &> /dev/null
        then
            #Valid SSid found, passing to script
            ssidChk=$ssid
            return 0
        else
            #No Network found, NoSSid issued"
            ssidChk='NoSSid'
        fi
    done
}

Main()
{
    GetWifiDetails
    FindSSID

    #Create Hotspot or connect to valid wifi networks
    if [ "$ssidChk" != "NoSSid" ] 
    then #ssid in range
        if systemctl status hostapd | grep "(running)" &> /dev/null
        then #hotspot running
            KillHotspot
            StartWifi
            ChkWifiUp
        elif { wpa_cli -i "$wifidev" status | grep 'ip_address'; } &> /dev/null
        then #ssid already connected
            echo "Wifi already connected to a network"
        else #ssid exists and no hotspot running connect to wifi network
            StartWifi
            ChkWifiUp
        fi
    else #ssid or MAC address not in range
        if systemctl status hostapd | grep "(running)" &> /dev/null
        then #Hostspot already running
            echo "Hostspot already active"
        elif { wpa_cli status | grep "$wifidev"; } &> /dev/null
        then #wifi active but hotspot not running
            ScrubWifi
            createAdHocNetwork
        else #No SSID, activating Hotspot
            createAdHocNetwork
        fi
    fi
}

Main
