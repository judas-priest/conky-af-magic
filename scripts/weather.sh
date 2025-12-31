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

IFS='|' read -r icon_emoji temp feels condition humidity wind moon_emoji moon_day <<< "$data"
temp=$(echo "$temp" | tr -d '+')
feels=$(echo "$feels" | tr -d '+')

# Convert weather emoji to Nerd Font icon with color
icon_emoji=$(echo "$icon_emoji" | tr -d ' ')
case "$icon_emoji" in
    ☀️|🌞)      icon="\${color3}󰖙\${color}" ;;   # sunny - yellow
    🌤️|⛅)      icon="\${color3}󰖕\${color}" ;;   # partly cloudy - yellow
    ☁️|🌥️)      icon="\${color6}󰖐\${color}" ;;   # cloudy - gray
    🌧️|🌦️)      icon="\${color4}󰖗\${color}" ;;   # rain - blue
    ⛈️|🌩️)      icon="\${color3}󰖓\${color}" ;;   # thunderstorm - yellow
    🌨️|❄️)      icon="\${color4}󰼶\${color}" ;;   # snow - blue
    🌫️|🌁)      icon="\${color6}󰖑\${color}" ;;   # fog - gray
    🌙|🌚)      icon="\${color3}󰖔\${color}" ;;   # night - yellow
    *)          icon="\${color6}󰖐\${color}" ;;   # default cloudy - gray
esac

# Convert moon day to phase name and icon (yellow)
moon_day_num=$(echo "$moon_day" | tr -d ' ')
case $moon_day_num in
    0)           moon_text="Новолуние"; moon_icon="" ;;
    [1-6])       moon_text="Растущий серп"; moon_icon="" ;;
    7)           moon_text="Первая четверть"; moon_icon="" ;;
    [8-9]|1[0-3]) moon_text="Растущая"; moon_icon="" ;;
    14|15)       moon_text="Полнолуние"; moon_icon="" ;;
    1[6-9]|2[0-1]) moon_text="Убывающая"; moon_icon="" ;;
    22)          moon_text="Последняя четверть"; moon_icon="" ;;
    2[3-9])      moon_text="Убывающий серп"; moon_icon="" ;;
    *)           moon_text="день $moon_day_num"; moon_icon="" ;;
esac

output="\${color0}WEATHER\${alignr}${temp}\${color}
\${color6}${CITY}\${alignr}\${font0}${icon}\${font} \${color}${condition}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind}
\${color6}Луна\${alignr}\${font0}\${color3}${moon_icon}\${color}\${font} ${moon_text}"

echo "$output" | tee "$CACHE"
