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

IFS='|' read -r icon temp feels condition humidity wind moon_icon moon_day <<< "$data"
icon=$(echo "$icon" | tr -d ' ')
temp=$(echo "$temp" | tr -d '+')
feels=$(echo "$feels" | tr -d '+')
moon_icon=$(echo "$moon_icon" | tr -d ' ')

# Convert moon day to phase name
moon_day_num=$(echo "$moon_day" | tr -d ' ')
case $moon_day_num in
    0)           moon_text="Новолуние" ;;
    [1-6])       moon_text="Растущий серп" ;;
    7)           moon_text="Первая четверть" ;;
    [8-9]|1[0-3]) moon_text="Растущая" ;;
    14|15)       moon_text="Полнолуние" ;;
    1[6-9]|2[0-1]) moon_text="Убывающая" ;;
    22)          moon_text="Последняя четверть" ;;
    2[3-9])      moon_text="Убывающий серп" ;;
    *)           moon_text="день $moon_day_num" ;;
esac

output="\${color0}WEATHER\${alignr}${temp}\${color}
\${font0}${icon}\${font} \${color6}${CITY}\${alignr}\${color}${condition}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind}
\${font0}${moon_icon}\${font} \${color6}Луна\${alignr}\${color}${moon_text}"

echo "$output" | tee "$CACHE"
