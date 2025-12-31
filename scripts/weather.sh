#!/bin/bash
#
# Weather script for Conky using wttr.in
# Part of conky-af-magic theme
#

# ============================================
# CONFIGURATION - Change these values
# ============================================
CITY="${CONKY_CITY:-Moscow}"      # Your city (or set CONKY_CITY env var)
LANG="${CONKY_LANG:-ru}"          # Language code

# ============================================
# Cache settings
# ============================================
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE="$CACHE_DIR/conky_weather"
CACHE_TIME=1800  # 30 minutes

# Create cache dir if needed
mkdir -p "$CACHE_DIR"

# Check cache validity
if [[ -f "$CACHE" ]]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if (( age < CACHE_TIME )); then
        cat "$CACHE"
        exit 0
    fi
fi

# Fetch weather data
get_weather() {
    curl -sf --max-time 5 "wttr.in/${CITY}?format=$1&lang=${LANG}" 2>/dev/null
}

temp=$(get_weather "%t" | tr -d '+')
feels=$(get_weather "%f" | tr -d '+')
condition=$(get_weather "%C")
humidity=$(get_weather "%h")
wind=$(get_weather "%w")

# Handle errors
if [[ -z "$temp" || "$temp" == "Unknown"* ]]; then
    echo '${color6}Нет данных${color}'
    exit 0
fi

# Generate output with Conky color codes
output="\${color6}${CITY}\${alignr}\${color0}${temp}\${color}
\${color5}${condition}\${color}
\${voffset 5}\${color6}Ощущается\${alignr}\${color}${feels}
\${color6}Влажность\${alignr}\${color}${humidity}
\${color6}Ветер\${alignr}\${color}${wind}"

# Save to cache and output
echo "$output" | tee "$CACHE"
