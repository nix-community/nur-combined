#!/bin/bash
#-------------------------------------------------------------------------------
# GLOBAL VARIABLES

# Define min & max CPU temperature in Grad Celsius
temp_min="@temp_min@"
temp_max="@temp_max@"

temp_delta=$(($temp_max - $temp_min))
temp_delta_1_percent=$(bc <<< "scale=2 ; $temp_delta / 100")

# Define min & max Fanspeed
fan_min="@temp_min@"
fan_max="@temp_max@"

fan_delta=$(($fan_max - $fan_min))
fan_delta_1_percent=$(bc <<< "scale=2 ; $fan_delta / 100")


#-------------------------------------------------------------------------------
# Main loop
last_cpu_temp=-100
while true
do
	# checking CPU temperature
	cpu_temp="$(cat /sys/class/thermal/thermal_zone0/temp)"

	if [ "$cpu_temp" -ge "$(($temp_max*1000))" ]; then
		cpu_state="is too high!"
	else
		cpu_state="is fine"
	fi

	# bringing CPU temperature in right format
	cpu_temp_string="$(($cpu_temp/1000))C"
	cpu_temp=$(($cpu_temp/1000))

	# echo CPU status
	echo "CPU " $cpu_state " with " $cpu_temp_string

	# regulate fan speed
	delta_cpu_temp=$(($cpu_temp - $temp_min))
	echo "delta_cpu_temp: " $delta_cpu_temp "C"

	fan_speed_percent=$(bc <<< "scale=2 ; $delta_cpu_temp / $temp_delta_1_percent")
	echo "fan_speed_percent: " $fan_speed_percent

	fan_speed=$(bc <<< "scale=0 ; ($fan_speed_percent * $fan_delta_1_percent + $fan_min) / 1")

	if [ "$fan_speed" -gt "$fan_max" ];then
		fan_speed=$fan_max
	fi

	if [ "$fan_speed" -lt "$fan_min" ];then
		fan_speed=$fan_min
	fi

	echo "fan_speed set to:"
	echo ""
	level=0
	delta_temp=$((cpu_temp-last_cpu_temp))
	delta_temp=${delta_temp#-}
	echo "delta_temp: $delta_temp"
	if ((delta_temp >= 2)); then
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
		echo "Level is: $level"
		echo $level | sudo tee /sys/class/thermal/cooling_device0/cur_state
		echo ""
	fi


	sleep 3
done
