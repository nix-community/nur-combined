#!/bin/bash
#-------------------------------------------------------------------------------
# GLOBAL VARIABLES

# Define min & max CPU temperature in Grad Celsius
temp_max="@temp_max@"

LOG_FILE=${LOG_FILE:=/var/log/rpi-fan/rpi-fan.log}
LOG_FOLDER=${LOG_FILE%/*}
mkdir -p "$LOG_FOLDER"
touch "$LOG_FILE"

check_overlay() {
	if [ ! -d "$OVERLAYS_DIR" ]; then
		OVERLAYS_DIR="@overlays_dir@"
		if [ ! -d "$OVERLAYS_DIR" ]; then
			echo "Overlays path: $OVERLAYS_DIR doesn't exist" >> $LOG_FILE
			exit 1
		fi
	fi
	if [ ! -f /sys/class/thermal/cooling_device0/cur_state ]; then
		echo "Trying to load rpi-poe overlay..." >> $LOG_FILE
		echo "Overlays path: $OVERLAYS_DIR" >> $LOG_FILE
		dtoverlay -l | grep rpi-poe || dtoverlay -d "$OVERLAYS_DIR" rpi-poe
	fi
}
check_overlay

#-------------------------------------------------------------------------------
# Main loop
last_cpu_temp=-100
last_level=0
count=0
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
	delta_temp=$((cpu_temp-last_cpu_temp))
	delta_temp=${delta_temp#-}

	level=0
	if ((delta_temp >= 3)); then
		last_cpu_temp=$cpu_temp
		if ((cpu_temp < 50)); then
			level=0
		fi
		if ((cpu_temp >= 50 && cpu_temp < 60)); then
			level=1
		fi
		if ((cpu_temp >= 60 && cpu_temp < 65)); then
			level=2
		fi
		if ((cpu_temp >= 65 && cpu_temp < 70)); then
			level=3
		fi
		if ((cpu_temp >= 70)); then
			level=4
		fi
		last_level=$level
	fi
	echo $last_level > /sys/class/thermal/cooling_device0/cur_state

	# echo CPU status
	count=$((count+1))
	if [ $count -ge 30 ]; then
		echo "$(date --iso-8601=s) CPU $cpu_state with $cpu_temp_string, Δ$delta_temp°C, level is `cat /sys/class/thermal/cooling_device0/cur_state`." >> $LOG_FILE
		count=0
	fi

	sleep 3
done
