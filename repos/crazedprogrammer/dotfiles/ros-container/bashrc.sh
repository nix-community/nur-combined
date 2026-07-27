#!/usr/bin/env bash

source /opt/ros/melodic/setup.bash
[ -f ./devel/setup.bash ] && source ./devel/setup.bash
alias catkut="catkin_make -DFranka_DIR:PATH=/opt/libfranka/build -Dfreenect2_DIR=/opt/freenect2/lib/cmake/freenect2"
alias runsim="roslaunch lidarps lidarps.launch"
alias dslam="roslaunch lidarps_ui debug_slam.launch"
alias webots="/opt/webots/webots"
