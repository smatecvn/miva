#!/bin/bash

# Load LED network trigger module
modprobe ledtrig-netdev

# Configure LEDs for eth0
echo eth0 > /sys/class/leds/link_led/device_name
echo eth0 > /sys/class/leds/led_speed/device_name

# Enable link and speed indicators
echo 1 > /sys/class/leds/link_led/link
echo 1 > /sys/class/leds/led_speed/tx
echo 1 > /sys/class/leds/led_speed/rx
