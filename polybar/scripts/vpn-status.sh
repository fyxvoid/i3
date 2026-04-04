#!/usr/bin/env bash
# Detect active VPN tunnel: tun*, tap*, wg* (OpenVPN / WireGuard / HTB / THM)

VPN_IF=$(ip -o link show up 2>/dev/null \
    | awk -F': ' '{print $2}' \
    | grep -E '^(tun|tap|wg)[0-9]' \
    | head -1)

if [[ -n "$VPN_IF" ]]; then
    IP=$(ip -4 addr show "$VPN_IF" 2>/dev/null \
         | awk '/inet / {print $2}' \
         | cut -d/ -f1 \
         | head -1)
    echo "%{F#6ED9A0}󰝉%{F-}  ${VPN_IF}  ${IP}"
else
    echo "%{F#4A7080}󰦞%{F-}  no vpn"
fi
