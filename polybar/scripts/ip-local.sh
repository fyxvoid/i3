#!/usr/bin/env bash
# Show primary non-loopback IP (prefers VPN tun0, then eth, then wlan)

for iface in tun0 tap0 eth0 eth1 wlan0 wlan1; do
    ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
    if [[ -n "$ip" ]]; then
        echo "󰩟 ${ip}"
        exit 0
    fi
done

echo "󰩟 no ip"
