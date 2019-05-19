#!/usr/bin/env bash

source /opt/ros/melodic/setup.bash
[ -f ./devel/setup.bash ] && source ./devel/setup.bash
alias catkut="catkin_make -DFranka_DIR:PATH=/root/libfranka/build -Dfreenect2_LIBRARY=/root/freenect2/lib/libfreenect2.so.0.2.0 -Dfreenect2_INCLUDE_DIR=/root/freenect2/include"
alias runsim="roslaunch src/wor-18-19-s2/simulation/sim_world/launch/world.launch"
