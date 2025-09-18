#!/bin/bash

theme="$HOME/.config/polybar/forest/scripts/rofi/networkmenu.rasi"

# Get list of available Wi-Fi networks
networks=$(nmcli -t -f SSID dev wifi | grep -v '^$' | sort | uniq)

# Show menu
chosen=$(echo "$networks" | rofi -dmenu -theme "$theme" -p "Connect to Wi-Fi")

# Exit if nothing selected
[ -z "$chosen" ] && exit

# Ask for password
password=$(rofi -dmenu -theme "$theme" -p "Password for $chosen")

# Connect using nmcli (quote SSID!)
nmcli dev wifi connect "$chosen" password "$password"

