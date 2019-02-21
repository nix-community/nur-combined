#!/usr/bin/env bash

source /opt/ros/melodic/setup.bash
if [ ! -f /tmp/.roslaunched ]; then
	touch /tmp/.roslaunched
	roscore > /dev/null &
else
	echo "Warning: ROS daemon already launched."
	read
fi

export MAKEFLAGS=-j$(nproc)

tmux
