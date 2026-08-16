#!/usr/bin/env bash
# Brightness OSD — adjusts backlight and pops a dunst progress notification.
set -euo pipefail

case "${1:-}" in
    up)   brightnessctl set +5% ;;
    down) brightnessctl set 5%- ;;
    *) echo "usage: $0 {up|down}"; exit 1 ;;
esac

pct=$(brightnessctl -m | awk -F, '{gsub("%","",$4); print $4}')
dunstify -a brightness -u low -r 9992 -h int:value:"$pct" "Brightness: ${pct}%"
