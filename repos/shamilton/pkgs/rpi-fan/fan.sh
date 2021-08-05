#!/bin/bash
#-------------------------------------------------------------------------------
# GLOBAL VARIABLES

# Define min & max CPU temperature in Grad Celsius
temp_min="@temp_min@"
temp_max="@temp_max@"

temp_delta=$(($temp_max - $temp_min))
temp_delta_1_percent=$(bc <<< "scale=2 ; $temp_delta / 100")

# Define min & max Fanspeed
fan_min="@fan_min@"
fan_max="@fan_max@"

fan_delta=$(($fan_max - $fan_min))
fan_delta_1_percent=$(bc <<< "scale=2 ; $fan_delta / 100")

check_overlay() {
	if [ ! -d "$OVERLAYS_PATH" ]; then
		echo "Overlays path: $OVERLAYS_PATH doesn't exist"
		exit 1
	fi
	if [ ! -f /sys/class/thermal/cooling_device0/cur_state ]; then
		echo "Trying to load rpi-poe overlay..."
		echo "Overlays path: $OVERLAYS_PATH"
		dtoverlay -l | grep rpi-poe || dtoverlay -d "$OVERLAYS_PATH" rpi-poe
	fi
}
check_overlay

#-------------------------------------------------------------------------------
# Main loop
last_cpu_temp=-100
last_level=0
while true
do
	check_overlay
	# checking CPU temperature
	cpu_temp="$(cat /sys/class/thermal/thermal_zone0/temp)"

	if [ "$cpu_temp" -ge "$(($temp_max*1000))" ]; then
		cpu_state="is too high!"
	else
		cpu_state="is fine"
	fi

	# bringing CPU temperature in right format
	cpu_temp_string="$(($cpu_temp/1000))°C"
	cpu_temp=$(($cpu_temp/1000))
	delta_cpu_temp=$(($cpu_temp - $temp_min))
	delta_temp=$((cpu_temp-last_cpu_temp))
	delta_temp=${delta_temp#-}

	# echo CPU status
	echo "CPU $cpu_state with $cpu_temp_string, Δ$delta_temp°C"

	fan_speed_percent=$(bc <<< "scale=2 ; $delta_cpu_temp / $temp_delta_1_percent")

	fan_speed=$(bc <<< "scale=0 ; ($fan_speed_percent * $fan_delta_1_percent + $fan_min) / 1")

	if [ "$fan_speed" -gt "$fan_max" ];then
		fan_speed=$fan_max
	fi

	if [ "$fan_speed" -lt "$fan_min" ];then
		fan_speed=$fan_min
	fi

	level=0
	if ((delta_temp >= 2)); then
		echo "fan_speed : $fan_speed"
		last_cpu_temp=$cpu_temp
		if ((fan_speed >= 0 && fan_speed < 51)); then
			level=0
		fi
		if ((fan_speed >= 51 && fan_speed < 102)); then
			level=1
		fi
		if ((fan_speed >= 102 && fan_speed < 153)); then
			level=2
		fi
		if ((fan_speed >= 153 && fan_speed < 204)); then
			level=3
		fi
		if ((fan_speed >= 204)); then
			level=4
		fi
		last_level=$level
		echo "Level is: $level"
		echo ""
	fi
	echo $last_level > /sys/class/thermal/cooling_device0/cur_state
	echo "Applied level `cat /sys/class/thermal/cooling_device0/cur_state`"

	sleep 3
done
