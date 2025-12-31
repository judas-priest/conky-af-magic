#!/bin/bash
# Get display info for Wayland/KDE

# Try kscreen-doctor first (KDE Plasma)
if command -v kscreen-doctor &>/dev/null; then
    kscreen-doctor -o 2>/dev/null | grep "^Output" | while read line; do
        name=$(echo "$line" | awk '{print $2}')
        # Get resolution from modes
        res=$(kscreen-doctor -o 2>/dev/null | grep -A5 "^Output.*$name" | grep -oP '\d+x\d+@\d+' | head -1)
        echo "$name $res"
    done | head -2 | tr '\n' '  '
    exit 0
fi

# Fallback: /sys/class/drm
for card in /sys/class/drm/card*-*; do
    if [[ -f "$card/status" ]] && grep -q "^connected$" "$card/status" 2>/dev/null; then
        name=$(basename "$card" | sed 's/card[0-9]-//')
        if [[ -f "$card/modes" ]]; then
            res=$(head -1 "$card/modes")
        fi
        echo "$name $res"
    fi
done | head -2 | tr '\n' '  '
