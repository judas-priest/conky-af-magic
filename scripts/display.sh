#!/bin/bash
# Get display info - combine hwinfo (correct size) with fastfetch (all displays)

# Get hwinfo data for size lookup
declare -A HWINFO_SIZE
while IFS= read -r line; do
    if [[ "$line" =~ Model:.*\"(.+)\" ]]; then
        current_model="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ Size:\ ([0-9]+)x([0-9]+) ]]; then
        w="${BASH_REMATCH[1]}"
        h="${BASH_REMATCH[2]}"
        diag=$(awk "BEGIN {printf \"%.0f\", sqrt($w*$w + $h*$h) / 25.4}")
        HWINFO_SIZE["$current_model"]="$diag"
    fi
done < <(hwinfo --monitor 2>/dev/null)

# Get displays from fastfetch and fix sizes using hwinfo
fastfetch --structure Display --logo none --pipe 2>/dev/null | while read -r line; do
    # Extract: Display (NAME): RESxRES in SIZE", FREQ Hz [TYPE]
    if [[ "$line" =~ Display\ \(([^)]+)\):\ ([0-9]+x[0-9]+).*\ ([0-9]+)\".*\ ([0-9]+)\ Hz\ \[([^\]]+)\] ]]; then
        name="${BASH_REMATCH[1]}"
        res="${BASH_REMATCH[2]}"
        size="${BASH_REMATCH[3]}"
        freq="${BASH_REMATCH[4]}"
        type="${BASH_REMATCH[5]}"

        # Try to find correct size from hwinfo
        for model in "${!HWINFO_SIZE[@]}"; do
            if [[ "$model" == *"$name"* ]] || [[ "$name" == *"$model"* ]]; then
                size="${HWINFO_SIZE[$model]}"
                break
            fi
        done

        echo "$name: ${res}@${freq}Hz, ${size}\""
    fi
done
