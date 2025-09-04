#!/bin/bash
GPIO=204

# Export GPIO if it is not already exported
if [ ! -d /sys/class/gpio/gpio$GPIO ]; then
    echo $GPIO > /sys/class/gpio/export
fi

# Set GPIO direction to output and set value to LOW
echo out > /sys/class/gpio/gpio$GPIO/direction
echo 0 > /sys/class/gpio/gpio$GPIO/value
sleep 2
echo 2 > /sys/class/gpio/gpio$GPIO/value
# Check for the presence of ttyUSB0, ttyUSB1, and ttyUSB2 for up to 10 seconds
TIMEOUT=20
for i in $(seq 1 $TIMEOUT); do
    if [ -e /dev/ttyUSB0 ] && [ -e /dev/ttyUSB1 ] && [ -e /dev/ttyUSB2 ]; then
        echo "All ttyUSB devices detected after $i sec."
        exit 0
    fi
    sleep 1
done

# If the timeout is reached and not all devices are detected, show a warning
echo "Warning: Not all ttyUSB devices detected after $TIMEOUT seconds."
exit 1
