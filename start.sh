#!/bin/bash
# Conky AF-Magic start script

killall conky 2>/dev/null
sleep 1

# Start all panels
conky -c ~/.config/conky/left.conf -d &
conky -c ~/.config/conky/right.conf -d &
conky -c ~/.config/conky/center-top.conf -d &
conky -c ~/.config/conky/center-bottom.conf -d &

echo "Conky started! (4 panels)"
