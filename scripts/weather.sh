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

# Get data - one call with custom format (u=M for m/s wind)
data=$(curl -sf --max-time 10 "wttr.in/${CITY}?format=%c|%t|%f|%C|%h|%w|%m|%M&u=M&lang=${LANG}" 2>/dev/null)

if [[ -z "$data" || "$data" == "Unknown"* ]]; then
    echo '${color6}Нет данных${color}'
    exit 0
fi

IFS='|' read -r icon temp feels condition humidity wind moon_icon moon_text <<< "$data"
icon=$(echo "$icon" | tr -d ' ')
temp=$(echo "$temp" | tr -d '+')
feels=$(echo "$feels" | tr -d '+')
moon_icon=$(echo "$moon_icon" | tr -d ' ')

output="\${color0}WEATHER\${alignr}${temp}\${color}
\${font0}${icon}\${font} \${color6}${CITY}\${alignr}\${color}${condition}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind}
\${font0}${moon_icon}\${font} \${color6}${moon_text}\${color}"

echo "$output" | tee "$CACHE"
