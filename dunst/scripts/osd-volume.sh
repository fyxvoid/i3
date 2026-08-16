#!/usr/bin/env bash
# Volume OSD — adjusts the default sink and pops a dunst progress notification.
set -euo pipefail

case "${1:-}" in
    up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
    down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
    mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    mic-mute)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
        dunstify -a volume -u low -r 9993 "Microphone" "$([[ "$muted" == "yes" ]] && echo Muted || echo Unmuted)"
        exit 0
        ;;
    *) echo "usage: $0 {up|down|mute|mic-mute}"; exit 1 ;;
esac

muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)

if [[ "$muted" == "yes" ]]; then
    dunstify -a volume -u low -r 9991 "Volume: muted"
else
    dunstify -a volume -u low -r 9991 -h int:value:"$vol" "Volume: ${vol}%"
fi
