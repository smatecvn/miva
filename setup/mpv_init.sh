#!/bin/bash
# */1 * * * * /usr/local/bin/mpv_init.sh >> /tmp/mpv_init.log 2>&1

sleep 10
CONTAINER_NAME="miva"
SOCKET_PATH_ZONE1="/tmp/mpv-zone1-socket"
SOCKET_PATH_ZONE2="/tmp/mpv-zone2-socket"
SOCKET_PATH_ZONE3="/tmp/mpv-zone3-socket"
MPV_LOGS_ZONE1="/tmp/zone1.log"
MPV_LOGS_ZONE2="/tmp/zone2.log"
MPV_LOGS_ZONE3="/tmp/zone3.log"
DOCKER_PATH="/home/miva/docker"
UPGRADE=/root/mgwp/upgrade/upgrade.tag

# Get main screen resolution
SCREEN_SIZE=$(DISPLAY=:0 XAUTHORITY=.Xauthority xrandr | grep '*' | awk '{print $1}')

# Get width and height
WIDTH=$(echo $SCREEN_SIZE | cut -d'x' -f1)
HEIGHT=$(echo $SCREEN_SIZE | cut -d'x' -f2)

echo "Screen width: $WIDTH"
echo "Screen height: $HEIGHT"

# Calculate partition sizes
PART1_HEIGHT=$((HEIGHT / 5))
PART2_HEIGHT=$((4 * HEIGHT / 5))
PART2_WIDTH=$((WIDTH / 2))

# Coordinates and sizes for each zone
X1=0
Y1=-20
W1=$WIDTH
H1=$PART1_HEIGHT

X2=0
Y2=$PART1_HEIGHT
W2=$PART2_WIDTH
H2=$PART2_HEIGHT

X3=$PART2_WIDTH
Y3=$PART1_HEIGHT
W3=$PART2_WIDTH
H3=$PART2_HEIGHT

# Open mpv zone 1,2,3
check_and_run_mpv() {
    local socket_path=$1
    local geometry=$2
    local title=$3
    local logs=$4

    # Check if mpv is already running with this socket
    if pgrep -f "mpv.*$socket_path" > /dev/null; then
        echo "mpv is already running: $socket_path"
    else
        echo "Starting mpv: $socket_path"
        DISPLAY=:0 XAUTHORITY=.Xauthority mpv --log-file="$logs" --msg-level=all=debug --title="$title" --no-border --no-keepaspect --geometry=$geometry --idle=yes --input-ipc-server=$socket_path --force-window --osc=no --no-audio &
    fi
}

sleep 1
check_and_run_mpv "${SOCKET_PATH_ZONE1}" "${W1}x${H1}+${X1}+${Y1}" "zone1" "${MPV_LOGS_ZONE1}"
sleep 2
check_and_run_mpv "${SOCKET_PATH_ZONE2}" "${W2}x${H2}+${X2}+${Y2}" "zone2" "${MPV_LOGS_ZONE2}"
sleep 2
check_and_run_mpv "${SOCKET_PATH_ZONE3}" "${W3}x${H3}+${X3}+${Y3}" "zone3" "${MPV_LOGS_ZONE3}"
sleep 3

# Example zone0 (disabled)
# SOCKET_PATH_ZONE0="/tmp/mpv-zone0-socket"
# if ! pgrep -f "mpv.*$SOCKET_PATH_ZONE0" > /dev/null; then
#     DISPLAY=:0 XAUTHORITY=.Xauthority mpv --log-file=/tmp/zone0.log --msg-level=all=debug --no-border --title="zone0" --idle=yes --input-ipc-server=$SOCKET_PATH_ZONE0 --force-window --fs --osc=no --no-audio &
#     echo "mpv started with socket $SOCKET_PATH_ZONE0"
# else
#     echo "mpv is already running with socket $SOCKET_PATH_ZONE0"
# fi

if [ -S "$SOCKET_PATH_ZONE3" ]; then
  echo "Socket $SOCKET_PATH_ZONE3 exists."

  # Check container
  if ! docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
      echo "Container $CONTAINER_NAME does not exist -> creating new one"
      TAG=$(cat "$UPGRADE" | tr -d ' \t\n')
      if [ -n "$TAG" ]; then
        echo "Detected new tag: $TAG"
        export TAG="$TAG"
      else 
        echo "Not Detected new tag: $TAG"
        export TAG=latest
      fi
      cd $DOCKER_PATH
      docker compose up -d
  else
      # Container exists
      if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
          echo "Container $CONTAINER_NAME exists but is not running -> starting"
          docker start $CONTAINER_NAME
      else
          echo "Container $CONTAINER_NAME is already running"
      fi
  fi
else
  echo "Socket $SOCKET_PATH_ZONE3 does not exist, container will not be started."
fi
