#!/usr/bin/env bash
Volume() {
    local VOLUME=$(amixer sget Master | grep -o '[0-9]*%' | head -n 1)
    echo -n "Volume: $VOLUME %"
}

Backlight() {
    local BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/brightness)
    echo -n "Backlight: $(($BRIGHTNESS / 15)) %"
}

Wifi() {
    local WIFI=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d: -f2 | head -n 1)
    if [ -v WIFI ]; then
        echo -n "Connected to: $WIFI"
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
    echo -n "Battery: $BATPERC %"
}

# Print the clock

while true; do
    echo "%{c}%{F#FFFF00}%{B#0000FF} $(Wifi) : $(Backlight) : $(Volume) : $(Battery) : $(Clock) %{F-}%{B-}"
        sleep 5
done
