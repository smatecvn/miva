#!/bin/bash
NETCFG=/root/mgwp/network/netplan.apply
REBOOT=/root/mgwp/reboot/reboot.apply
UPGRADE=/root/mgwp/upgrade/upgrade.tag
WATCHERDIR=/root/mgwp
COMPOSE_DIR=/home/mira/docker

inotifywait -m -r -e close_write "$WATCHERDIR" | while read path action file; do
  case "$file" in
    $(basename "$NETCFG"))
        REQ=$(cat "$NETCFG" | tr -d ' \t\n')
        if [ "$REQ" == "Request" ]; then
          netplan apply
          echo "Done" > $NETCFG
        else
          echo "netplan apply done..."
        fi
        ;;
    $(basename "$UPGRADE"))
      cd "$COMPOSE_DIR"
      TAG=$(cat "$UPGRADE" | tr -d ' \t\n')
      if [ -n "$TAG" ]; then
          echo "Detected new tag: $TAG"
          export TAG="$TAG"

          echo "Pulling new image..."
          docker compose pull

          echo "Restarting container..."
          docker compose up -d

          echo "Delete unused images..."
          docker image prune -a -f
      fi
      ;;
    $(basename "$REBOOT"))
      RB=$(cat "$REBOOT" | tr -d ' \t\n')
      if [ "$RB" == "Request" ]; then
          echo "Reboot" > $REBOOT
          sleep 1
          reboot
      fi
      ;;      
  esac
done
