#!/usr/bin/env bash

# Settings
battery_percent_MODULUS=5 # How many percent difference are required for another update
INTERVAL=20 # The interval at which to check the battery percentage
ALERT_SCRIPT="sudo /home/mia/Scripts/keyboard_alert.sh"

# Battery Levels
BAT_RECOMMENDED_UPPER_LIMIT=80
BAT_RECOMMENDED_LOWER_LIMIT=30
BAT_SLIGHTLY_LOW=25
BAT_LOW=17
BAT_VERY_LOW=10
BAT_HIB=5

force_notification=0
last_battery_percent=0

get_percentage()
{
    echo $(cat /sys/bus/acpi/drivers/battery/*/power_supply/BAT?/capacity)
}

countdown()
{
    for i in $(seq 1 15);
    do
        if [[ $(cat /sys/bus/acpi/drivers/battery/*/power_supply/BAT?/status) = "Charging" ]]; then
            return
        fi

        sleep 4
        notify-send $((10-$i)) -u critical
    done
    systemctl hibernate
}

while true; 
do
    sleep $INTERVAL

    battery_percent=$(get_percentage)

    if [[ $battery_percent -eq $last_battery_percent ]]; then
        continue
    fi

    if [[ $(( battery_percent % $battery_percent_MODULUS )) -ne 0 && $force_notification -ne 1 ]]; then
        continue
    fi

    # Is battery charging?
    if [[ $(cat /sys/bus/acpi/drivers/battery/*/power_supply/BAT?/status) = "Charging" ]]; then
        if [[ $battery_percent -ge $BAT_RECOMMENDED_UPPER_LIMIT ]]; then
            notify-send "Im full!" -u low
            $ALERT_SCRIPT
        fi    

    # Is battery discharging?
    else
        if [[ $battery_percent -le $BAT_HIB ]]; then
            notify-send "Self destructing in T Minus 10 Seconds..." -u critical &&
            countdown
        elif [[ $battery_percent -le $BAT_VERY_LOW ]]; then
            notify-send "I beg you, I'm about to die!" -u critical &&
	    $ALERT_SCRIPT 5
        elif [[ $battery_percent -le $BAT_LOW ]]; then
           notify-send "Can you please plug me in aleady? I'm dying!" -u normal &&
 	    $ALERT_SCRIPT 2
       elif [[ $battery_percent -le $BAT_SLIGHTLY_LOW ]]; then
            notify-send "I'd need a recharge about now pwp" -u normal &&
            $ALERT_SCRIPT 1
        elif [[ $battery_percent -le $BAT_RECOMMENDED_LOWER_LIMIT ]]; then
            notify-send "Please plug me in pwp" -u low
        fi
    fi

    last_battery_percent=$battery_percent
done
