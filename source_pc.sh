#!/usr/bin/env bash
# Source ROS 2 Lyrical and Fast DDS 3 for communicating with a Rosdroid phone.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source /opt/ros/lyrical/setup.bash

export ROS_DOMAIN_ID=156
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export FASTDDS_DEFAULT_PROFILES_FILE="$SCRIPT_DIR/fastdds_pc.xml"

# Restart ros2 daemon to pick up the new middleware and profile.
ros2 daemon stop >/dev/null 2>&1 || true

echo "=== Rosdroid PC Environment Configured ==="
echo "ROS_DISTRO: $ROS_DISTRO"
echo "ROS_DOMAIN_ID: $ROS_DOMAIN_ID"
echo "RMW_IMPLEMENTATION: $RMW_IMPLEMENTATION"
echo "FASTDDS_DEFAULT_PROFILES_FILE: $FASTDDS_DEFAULT_PROFILES_FILE"
echo ""
echo "Test phone connection with:"
echo "  ros2 topic list"
echo "  ros2 topic echo /battery"
echo "=========================================="
