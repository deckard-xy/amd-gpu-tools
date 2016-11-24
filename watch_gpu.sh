#!/bin/bash

#sudo watch -n1 cat /sys/class/drm/card0/device/hwmon/hwmon0/pwm1 /sys/class/drm/card0/device/hwmon/hwmon0/temp1_input /sys/kernel/debug/dri/0/amdgpu_pm_info
watch -n1 amd-sensors.sh
