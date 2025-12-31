#!/bin/bash
#
# Weather script for Conky using wttr.in
#

CITY="${CONKY_CITY:-Moscow}"
LANG="${CONKY_LANG:-ru}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE="$CACHE_DIR/conky_weather"
CACHE_TIME=1800

mkdir -p "$CACHE_DIR"

if [[ -f "$CACHE" ]]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if (( age < CACHE_TIME )); then
        cat "$CACHE"
        exit 0
    fi
fi

get_weather() {
    curl -sf --max-time 5 "wttr.in/${CITY}?format=$1&lang=${LANG}" 2>/dev/null
}

# Get data - one call with custom format
data=$(curl -sf --max-time 10 "wttr.in/${CITY}?format=%c|%t|%f|%C|%h|%w&lang=${LANG}" 2>/dev/null)

if [[ -z "$data" || "$data" == "Unknown"* ]]; then
    echo '${color6}Нет данных${color}'
    exit 0
fi

IFS='|' read -r icon temp feels condition humidity wind <<< "$data"
icon=$(echo "$icon" | tr -d ' ')
temp=$(echo "$temp" | tr -d '+')
feels=$(echo "$feels" | tr -d '+')

output="${icon} \${color6}${CITY}\${alignr}\${color0}${temp}\${color}
\${color5}${condition}\${color}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind}"

echo "$output" | tee "$CACHE"
