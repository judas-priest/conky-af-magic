#!/bin/bash
# Get display info - combine hwinfo (correct size) with fastfetch (all displays)

# Build hwinfo size map
declare -A HWINFO_SIZE
current_model=""
while IFS= read -r line; do
    case "$line" in
        *Model:*)
            current_model=$(echo "$line" | sed 's/.*Model: "\([^"]*\)".*/\1/')
            ;;
        *Size:*)
            if [ -n "$current_model" ]; then
                w=$(echo "$line" | sed 's/.*Size: \([0-9]*\)x.*/\1/')
                h=$(echo "$line" | sed 's/.*x\([0-9]*\) mm.*/\1/')
                if [ -n "$w" ] && [ -n "$h" ]; then
                    diag=$(awk "BEGIN {printf \"%.0f\", sqrt($w*$w + $h*$h) / 25.4}")
                    HWINFO_SIZE["$current_model"]="$diag"
                fi
            fi
            ;;
    esac
done < <(hwinfo --monitor 2>/dev/null)

# Parse fastfetch output
fastfetch --structure Display --logo none --pipe 2>/dev/null | while read -r line; do
    # Display (NAME): 1920x1080 in 22", 60 Hz [External]
    name=$(echo "$line" | sed -n 's/Display (\([^)]*\)).*/\1/p')
    [ -z "$name" ] && continue

    res=$(echo "$line" | grep -oP '\d+x\d+' | head -1)
    size=$(echo "$line" | grep -oP 'in \K\d+' | head -1)
    freq=$(echo "$line" | grep -oP '\d+ Hz' | head -1 | cut -d' ' -f1)

    # Try to find correct size from hwinfo
    for model in "${!HWINFO_SIZE[@]}"; do
        if [[ "$model" == *"$name"* ]] || [[ "$name" == *"$model"* ]] || [[ "$model" == *SAMSUNG* && "$name" == *SAMSUNG* ]]; then
            size="${HWINFO_SIZE[$model]}"
            break
        fi
    done

    echo "$name: ${res}@${freq}Hz, ${size}\""
done
