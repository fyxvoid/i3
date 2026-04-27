#!/usr/bin/env bash
# HackTheBox / TryHackMe target info — reads ~/.config/pentest/target
# Format in target file:  NAME IP
# Example:                MonitorsThree 10.10.11.33

TARGET_FILE="$HOME/.config/pentest/target"

if [[ -f "$TARGET_FILE" ]]; then
    read -r name ip < "$TARGET_FILE"
    if [[ -n "$name" && -n "$ip" ]]; then
        echo "%{T3}%{F#FFFFFF}󰓾%{F-}%{T-}  %{F#F0CCCC}${name}%{F-}  %{F#FF2244}${ip}%{F-}"
        exit 0
    fi
fi

echo "%{T3}%{F#662222}󰓾%{F-}%{T-}  no target"
