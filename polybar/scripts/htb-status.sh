#!/usr/bin/env bash
# HackTheBox / TryHackMe target info — reads ~/.config/pentest/target
# Format in target file:  NAME IP
# Example:                MonitorsThree 10.10.11.33

TARGET_FILE="$HOME/.config/pentest/target"

if [[ -f "$TARGET_FILE" ]]; then
    read -r name ip < "$TARGET_FILE"
    if [[ -n "$name" && -n "$ip" ]]; then
        echo "%{F#E87DA0}%{F-}  %{F#D8EEF8}${name}%{F-}  %{F#5BBAD6}${ip}%{F-}"
        exit 0
    fi
fi

echo "%{F#4A7080}%{F-}  no target%{F-}"
