#!/usr/bin/env bash
# Polybar launch — aligns bar width with i3 outer gaps

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 0.1; done

# Match i3 outer gap (gaps outer 6)
GAP=6

SCREEN_W=$(xrandr --current 2>/dev/null \
    | awk '/ connected / { match($0, /[0-9]+x[0-9]+\+0/); if (RSTART) print substr($0, RSTART, RLENGTH) }' \
    | cut -dx -f1 | head -1)
SCREEN_W=${SCREEN_W:-1920}

export POLYBAR_W=$(( SCREEN_W - GAP * 2 ))
export POLYBAR_X=$GAP

polybar main 2>&1 | tee -a /tmp/polybar-main.log &

echo "Polybar launched  (screen=${SCREEN_W}  bar_w=${POLYBAR_W}  offset_x=${POLYBAR_X})"
