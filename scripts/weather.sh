#!/bin/bash
#
# Weather script for Conky using wttr.in
#

CITY="${CONKY_CITY:-Moscow}"

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

# Get data in English - one call with custom format (u=M for m/s wind)
data=$(curl -sf --max-time 10 "wttr.in/${CITY}?format=%c|%t|%f|%C|%h|%w|%m|%M&u=M&lang=en" 2>/dev/null)

if [[ -z "$data" || "$data" == "Unknown"* ]]; then
    echo '${color6}Нет данных${color}'
    exit 0
fi

IFS='|' read -r icon_emoji temp feels condition humidity wind moon_emoji moon_day <<< "$data"
temp=$(echo "$temp" | tr -d '+')
feels=$(echo "$feels" | tr -d '+')

# English to Russian weather dictionary
case "$condition" in
    # Clear/Sunny
    "Clear"|"Sunny")                          condition="Ясно" ;;
    "Partly cloudy"|"Partly Cloudy")          condition="Облачно" ;;
    "Cloudy"|"Overcast")                      condition="Пасмурно" ;;

    # Rain
    "Patchy rain possible")                   condition="Возможен дождь" ;;
    "Patchy light drizzle"|"Light drizzle")   condition="Морось" ;;
    "Drizzle"|"Freezing drizzle")             condition="Морось" ;;
    "Light rain"|"Patchy light rain")         condition="Небольшой дождь" ;;
    "Moderate rain"|"Moderate rain at times") condition="Дождь" ;;
    "Heavy rain"|"Heavy rain at times")       condition="Сильный дождь" ;;
    "Light rain shower"|"Light showers")      condition="Небольшой дождь" ;;
    "Moderate or heavy rain shower")          condition="Ливень" ;;
    "Torrential rain shower")                 condition="Сильный ливень" ;;

    # Freezing rain
    "Freezing rain"|"Light freezing rain")    condition="Ледяной дождь" ;;
    "Moderate or heavy freezing rain")        condition="Ледяной дождь" ;;

    # Snow
    "Patchy snow possible")                   condition="Возможен снег" ;;
    "Patchy light snow"|"Light snow")         condition="Небольшой снег" ;;
    "Moderate snow"|"Patchy moderate snow")   condition="Снег" ;;
    "Heavy snow"|"Patchy heavy snow")         condition="Сильный снег" ;;
    "Light snow showers")                     condition="Небольшой снег" ;;
    "Moderate or heavy snow showers")         condition="Снегопад" ;;
    "Blowing snow"|"Blizzard")                condition="Метель" ;;

    # Sleet
    "Sleet"|"Light sleet"|"Light sleet showers") condition="Мокрый снег" ;;
    "Moderate or heavy sleet"*)               condition="Мокрый снег" ;;
    "Ice pellets"|"Light showers of ice pellets") condition="Град" ;;
    "Moderate or heavy showers of ice pellets")   condition="Сильный град" ;;

    # Thunderstorm
    *"thundery"*|*"thunder"*)                 condition="Гроза" ;;
    "Thunderstorm"|"Thundery outbreaks"*)     condition="Гроза" ;;

    # Fog/Mist
    "Mist")                                   condition="Дымка" ;;
    "Fog"|"Freezing fog")                     condition="Туман" ;;

    # Fallback - keep original if short, otherwise truncate
    *)
        if (( ${#condition} > 18 )); then
            condition=$(echo "$condition" | cut -c1-18)
        fi ;;
esac

# Nerd Font icons (using printf for correct UTF-8)
NF_SUNNY=$(printf '\xf3\xb0\x96\x99')      # nf-md-weather_sunny
NF_PCLOUDY=$(printf '\xf3\xb0\x96\x95')    # nf-md-weather_partly_cloudy
NF_CLOUDY=$(printf '\xf3\xb0\x96\x90')     # nf-md-weather_cloudy
NF_RAINY=$(printf '\xf3\xb0\x96\x97')      # nf-md-weather_rainy
NF_THUNDER=$(printf '\xf3\xb0\x96\x93')    # nf-md-weather_lightning
NF_SNOWY="❄︎"                              # Unicode snowflake + FE0E (text style)
NF_FOG=$(printf '\xf3\xb0\x96\x91')        # nf-md-weather_fog
NF_NIGHT=$(printf '\xf3\xb0\x96\x94')      # nf-md-weather_night

# Convert weather emoji to icon with color
icon_emoji=$(echo "$icon_emoji" | tr -d ' ')
case "$icon_emoji" in
    *☀*|*🌞*)   icon="\${font0}\${color3}${NF_SUNNY}\${font}\${color}" ;;
    *🌤*|*⛅*)   icon="\${font0}\${color3}${NF_PCLOUDY}\${font}\${color}" ;;
    *☁*|*🌥*)   icon="\${font0}\${color6}${NF_CLOUDY}\${font}\${color}" ;;
    *🌧*|*🌦*)   icon="\${font0}\${color4}${NF_RAINY}\${font}\${color}" ;;
    *⛈*|*🌩*)   icon="\${font0}\${color3}${NF_THUNDER}\${font}\${color}" ;;
    *🌨*|*❄*)   icon="\${font0}\${color4}${NF_SNOWY}\${font}\${color}" ;;
    *🌫*|*🌁*)   icon="\${font0}\${color6}${NF_FOG}\${font}\${color}" ;;
    *🌙*|*🌚*)   icon="\${font0}\${color3}${NF_NIGHT}\${font}\${color}" ;;
    *)          icon="\${font0}\${color6}${NF_CLOUDY}\${font}\${color}" ;;
esac

# Wind direction arrows with colors
# North (↓) = blue (cold), South (↑) = orange (warm), East/West = gray
wind_arrow="${wind:0:1}"
wind_kmh=$(echo "$wind" | grep -oE '[0-9]+')
wind_ms=$(awk "BEGIN {printf \"%.0f\", $wind_kmh / 3.6}")

case "$wind_arrow" in
    ↓)  wind_colored="\${font0}\${color4}↓\${font}\${color}${wind_ms}m/s" ;;   # north=blue
    ↑)  wind_colored="\${font0}\${color3}↑\${font}\${color}${wind_ms}m/s" ;;   # south=orange
    ←)  wind_colored="\${font0}\${color6}←\${font}\${color}${wind_ms}m/s" ;;   # east=gray
    →)  wind_colored="\${font0}\${color6}→\${font}\${color}${wind_ms}m/s" ;;   # west=gray
    ↘)  wind_colored="\${font0}\${color4}↘\${font}\${color}${wind_ms}m/s" ;;   # NE=blue
    ↙)  wind_colored="\${font0}\${color4}↙\${font}\${color}${wind_ms}m/s" ;;   # NW=blue
    ↗)  wind_colored="\${font0}\${color3}↗\${font}\${color}${wind_ms}m/s" ;;   # SE=orange
    ↖)  wind_colored="\${font0}\${color3}↖\${font}\${color}${wind_ms}m/s" ;;   # SW=orange
    *)  wind_colored="${wind_ms}m/s" ;;
esac

# Convert moon day to phase name and icon
moon_day_num=$(echo "$moon_day" | tr -d ' ')
case $moon_day_num in
    0)            moon_icon="🌑"; moon_text="Новолуние" ;;
    [1-6])        moon_icon="🌒"; moon_text="Растущий серп" ;;
    7)            moon_icon="🌓"; moon_text="Первая четверть" ;;
    [8-9]|1[0-3]) moon_icon="🌔"; moon_text="Растущая" ;;
    14|15)        moon_icon="🌕"; moon_text="Полнолуние" ;;
    1[6-9]|2[0-1]) moon_icon="🌖"; moon_text="Убывающая" ;;
    22)           moon_icon="🌗"; moon_text="Последняя четверть" ;;
    2[3-9])       moon_icon="🌘"; moon_text="Убывающий серп" ;;
    *)            moon_icon="🌙"; moon_text="день $moon_day_num" ;;
esac

output="\${color0}WEATHER\${alignr}${temp}\${color}
\${color6}${CITY}\${alignr}${icon} ${condition}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}${wind_colored}
\${color6}Луна\${alignr}\${color3}${moon_icon}\${color} ${moon_text}"

echo "$output" | tee "$CACHE"
