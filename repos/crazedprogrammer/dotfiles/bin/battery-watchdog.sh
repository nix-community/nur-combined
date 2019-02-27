#!/bin/sh

battery_percentage=$(< /sys/class/power_supply/BAT0/capacity)
charging=$(< /sys/class/power_supply/AC/online)

if [ $battery_percentage -lt 10 ] && [ $charging -eq 0 ]; then
	echo "Battery low. Shutting down to prevent battery damage."
	systemctl poweroff
fi
