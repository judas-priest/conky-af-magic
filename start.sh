#!/bin/bash
# Conky AF-Magic start script
# Run from repository directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/conky"

# Create symlink for scripts (configs reference ~/.config/conky/scripts/)
mkdir -p "$CONFIG_DIR"
rm -rf "$CONFIG_DIR/scripts"
ln -sf "$SCRIPT_DIR/scripts" "$CONFIG_DIR/scripts"

# Clear weather cache
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/conky_weather"

# Kill existing conky
killall conky 2>/dev/null
sleep 0.5

# Start all panels from repository
conky -c "$SCRIPT_DIR/left.conf" -d &
conky -c "$SCRIPT_DIR/right.conf" -d &
conky -c "$SCRIPT_DIR/center-top.conf" -d &
conky -c "$SCRIPT_DIR/center-bottom.conf" -d &

echo "Conky started! (4 panels)"
echo "Scripts linked: $CONFIG_DIR/scripts -> $SCRIPT_DIR/scripts"
