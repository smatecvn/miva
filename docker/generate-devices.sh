#!/bin/bash
OUTPUT="docker-compose.override.yml"

echo "#version: '3.9'" > $OUTPUT
echo "services:" >> $OUTPUT
echo "  mira:" >> $OUTPUT
echo "    devices:" >> $OUTPUT

for dev in /dev/ttyUSB* /dev/i2c-* /dev/gpiochip* /dev/ttyS* /dev/rtc*; do
  if [ -e "$dev" ]; then
    echo "      - \"$dev\"" >> $OUTPUT
  fi
done

echo "File $OUTPUT đã được tạo."
