#!/bin/bash
#
# Weather script for Conky using wttr.in
#

# ============================================
# CONFIGURATION
# ============================================
CITY="${CONKY_CITY:-Moscow}"
LANG="${CONKY_LANG:-ru}"

# ============================================
# Cache settings
# ============================================
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE="$CACHE_DIR/conky_weather"
CACHE_TIME=1800  # 30 minutes

mkdir -p "$CACHE_DIR"

# Check cache
if [[ -f "$CACHE" ]]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if (( age < CACHE_TIME )); then
        cat "$CACHE"
        exit 0
    fi
fi

# Fetch weather
get_weather() {
    curl -sf --max-time 5 "wttr.in/${CITY}?format=$1&lang=${LANG}" 2>/dev/null
}

icon=$(get_weather "%c" | tr -d ' ')
temp=$(get_weather "%t" | tr -d '+')
feels=$(get_weather "%f" | tr -d '+')
condition=$(get_weather "%C")
humidity=$(get_weather "%h")
wind=$(get_weather "%w")

if [[ -z "$temp" || "$temp" == "Unknown"* ]]; then
    echo '${color6}Нет данных${color}'
    exit 0
fi

# Output with icon
output="${icon} \${color6}${CITY}\${alignr}\${color0}${temp}\${color}
\${color5}${condition}\${color}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind}"

echo "$output" | tee "$CACHE"
