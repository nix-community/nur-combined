#!/usr/bin/env bash

Wifi() {
    local WIFI=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d: -f2)
    if [ -n WIFI ]; then
        echo -n "Connected on: $WIFI"
    else
        echo -n "Not connected to WiFi"
    fi
}

Clock() {
    local DATETIME=$(date "+%a %b %d, %H:%M")
    echo -n "$DATETIME"
}

Battery() {
    local BATPERC=$(cat /sys/class/power_supply/BAT0/capacity)
    echo -n "$BATPERC %"
}

# Print the clock

while true; do
    echo "%{c}%{F#FFFF00}%{B#0000FF}$(Wifi) : Battery: $(Battery) : $(Clock) %{F-}%{B-}"
        sleep 20
done
