#!/usr/bin/env bash

source /opt/ros/melodic/setup.bash
[ -f ./devel/setup.bash ] && source ./devel/setup.bash
alias catkut="catkin_make -DFranka_DIR:PATH=/root/libfranka/build -Dfreenect2_DIR=/root/freenect2/lib/cmake/freenect2"
alias runsim="roslaunch sim_world world.launch"
