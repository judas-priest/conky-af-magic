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

# Get data - one call with custom format (u=M for m/s wind)
data=$(curl -sf --max-time 10 "wttr.in/${CITY}?format=%c|%t|%f|%C|%h|%w|%m|%M&u=M&lang=${LANG}" 2>/dev/null)

if [[ -z "$data" || "$data" == "Unknown"* ]]; then
    echo '${color6}Нет данных${color}'
    exit 0
fi

IFS='|' read -r icon_emoji temp feels condition humidity wind moon_emoji moon_day <<< "$data"
temp=$(echo "$temp" | tr -d '+')
feels=$(echo "$feels" | tr -d '+')

# Nerd Font icons (using printf for correct UTF-8)
NF_SUNNY=$(printf '\xf3\xb0\x96\x99')      # nf-md-weather_sunny
NF_PCLOUDY=$(printf '\xf3\xb0\x96\x95')    # nf-md-weather_partly_cloudy
NF_CLOUDY=$(printf '\xf3\xb0\x96\x90')     # nf-md-weather_cloudy
NF_RAINY=$(printf '\xf3\xb0\x96\x97')      # nf-md-weather_rainy
NF_THUNDER=$(printf '\xf3\xb0\x96\x93')    # nf-md-weather_lightning
NF_SNOWY=$(printf '\xf3\xb0\x96\x9c')      # nf-md-weather_snowy
NF_FOG=$(printf '\xf3\xb0\x96\x91')        # nf-md-weather_fog
NF_NIGHT=$(printf '\xf3\xb0\x96\x94')      # nf-md-weather_night

# Convert weather emoji to Nerd Font icon with color
icon_emoji=$(echo "$icon_emoji" | tr -d ' ')
case "$icon_emoji" in
    *☀*|*🌞*)   icon="\${color3}${NF_SUNNY}\${color}" ;;
    *🌤*|*⛅*)   icon="\${color3}${NF_PCLOUDY}\${color}" ;;
    *☁*|*🌥*)   icon="\${color6}${NF_CLOUDY}\${color}" ;;
    *🌧*|*🌦*)   icon="\${color4}${NF_RAINY}\${color}" ;;
    *⛈*|*🌩*)   icon="\${color3}${NF_THUNDER}\${color}" ;;
    *🌨*|*❄*)   icon="\${color4}${NF_SNOWY}\${color}" ;;
    *🌫*|*🌁*)   icon="\${color6}${NF_FOG}\${color}" ;;
    *🌙*|*🌚*)   icon="\${color3}${NF_NIGHT}\${color}" ;;
    *)          icon="\${color6}${NF_CLOUDY}\${color}" ;;
esac

# Nerd Font arrows for wind direction with colors
# North (↓) = blue (cold), South (↑) = orange (warm), East/West = gray
NF_ARR_DOWN=$(printf '\xf3\xb0\x9c\xae')   # 󰜮 nf-md-arrow_down_bold
NF_ARR_UP=$(printf '\xf3\xb0\x9c\xb7')     # 󰜷 nf-md-arrow_up_bold
NF_ARR_LEFT=$(printf '\xf3\xb0\x9c\xb1')   # 󰜱 nf-md-arrow_left_bold
NF_ARR_RIGHT=$(printf '\xf3\xb0\x9c\xb4')  # 󰜴 nf-md-arrow_right_bold

# Convert km/h to m/s
wind_arrow="${wind:0:1}"
wind_kmh=$(echo "$wind" | grep -oE '[0-9]+')
wind_ms=$(awk "BEGIN {printf \"%.0f\", $wind_kmh / 3.6}")

case "$wind_arrow" in
    ↓)  wind_colored="\${color4}${NF_ARR_DOWN}\${color}${wind_ms}m/s" ;;   # north=blue
    ↑)  wind_colored="\${color3}${NF_ARR_UP}\${color}${wind_ms}m/s" ;;     # south=orange
    ←)  wind_colored="\${color6}${NF_ARR_LEFT}\${color}${wind_ms}m/s" ;;   # east=gray
    →)  wind_colored="\${color6}${NF_ARR_RIGHT}\${color}${wind_ms}m/s" ;;  # west=gray
    ↘)  wind_colored="\${color4}${NF_ARR_DOWN}\${color}${wind_ms}m/s" ;;   # NE=blue
    ↙)  wind_colored="\${color4}${NF_ARR_DOWN}\${color}${wind_ms}m/s" ;;   # NW=blue
    ↗)  wind_colored="\${color3}${NF_ARR_UP}\${color}${wind_ms}m/s" ;;     # SE=orange
    ↖)  wind_colored="\${color3}${NF_ARR_UP}\${color}${wind_ms}m/s" ;;     # SW=orange
    *)  wind_colored="${wind_ms}m/s" ;;
esac

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
\${color6}${CITY}\${alignr}\${font0}${icon}\${font} \${color}${condition}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind_colored}
\${color6}Луна\${alignr}\${font0}\${color3}${NF_NIGHT}\${font}\${color} ${moon_text}"

echo "$output" | tee "$CACHE"
