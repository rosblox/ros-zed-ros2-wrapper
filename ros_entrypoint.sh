#!/bin/bash
# set -e

id -u ros &>/dev/null || adduser --quiet --disabled-password --gecos '' --uid ${UID:=1000} --uid ${GID:=1000} ros

usermod -aG staff ros
usermod -aG video ros

source "/opt/ros/$ROS_DISTRO/install/setup.bash"
source /colcon_ws/install/setup.bash


# Welcome information
echo "ZED ROS2 Docker Image"
echo "---------------------"
echo 'ROS distro: ' $ROS_DISTRO
echo 'DDS middleware: ' $RMW_IMPLEMENTATION 
echo "---"  
echo 'Available ZED packages:'
ros2 pkg list | grep zed
echo "---------------------"   

exec "$@"