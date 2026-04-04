#!/usr/bin/env bash
# Show download/upload speed for the primary active network interface
# Uses a state file — no sleep, works with polybar interval polling

STATE="/tmp/polybar-netspeed"

# Find primary active interface (priority: tun/tap > eth/en > wlan/wl > any)
IFACE=""

_find_up() {
    local pattern="$1"
    for iface in $(ls /sys/class/net/ 2>/dev/null | grep -E "$pattern"); do
        if [[ "$(cat /sys/class/net/$iface/operstate 2>/dev/null)" == "up" ]]; then
            echo "$iface"; return
        fi
    done
}

IFACE=$(_find_up '^(tun|tap)[0-9]')
[[ -z "$IFACE" ]] && IFACE=$(_find_up '^(eth|en)[a-z0-9]')
[[ -z "$IFACE" ]] && IFACE=$(_find_up '^(wlan|wlp|wl)[a-z0-9]')

if [[ -z "$IFACE" ]]; then
    # Last resort: any non-loopback up interface
    for iface in $(ls /sys/class/net/ 2>/dev/null); do
        [[ "$iface" == "lo" ]] && continue
        if [[ "$(cat /sys/class/net/$iface/operstate 2>/dev/null)" == "up" ]]; then
            IFACE="$iface"; break
        fi
    done
fi

[[ -z "$IFACE" ]] && exit 0

RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
NOW=$(date +%s%N)

_fmt() {
    local s=$1
    [[ $s -lt 0 ]] && s=0
    if [[ $s -ge 1024 ]]; then
        printf "%dM" $(( s / 1024 ))
    else
        printf "%dK" $s
    fi
}

if [[ -f "$STATE" ]]; then
    read -r L_IFACE L_RX L_TX L_TIME < "$STATE" 2>/dev/null
    if [[ "$L_IFACE" == "$IFACE" && -n "$L_RX" && -n "$L_TIME" ]]; then
        ELAPSED=$(( (NOW - L_TIME) / 1000000 ))
        if [[ $ELAPSED -gt 200 ]]; then
            RX_S=$(( (RX - L_RX) * 1000 / ELAPSED / 1024 ))
            TX_S=$(( (TX - L_TX) * 1000 / ELAPSED / 1024 ))
            echo "%{F#6ED9A0}%{T2}󰁅%{T-}%{F-}$(_fmt $RX_S) %{F#F0C040}%{T2}󰁞%{T-}%{F-}$(_fmt $TX_S)"
            echo "$IFACE $RX $TX $NOW" > "$STATE"
            exit 0
        fi
    fi
fi

echo "$IFACE $RX $TX $NOW" > "$STATE"
echo "%{F#4A7080}%{T2}󰁅%{T-}%{F-}--- %{F#4A7080}%{T2}󰁞%{T-}%{F-}---"
