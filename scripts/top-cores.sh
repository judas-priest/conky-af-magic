#!/bin/bash
#
# Show top N most loaded CPU cores
#

TOP_N="${1:-8}"

# Get per-core CPU usage using mpstat or fallback
if command -v mpstat &>/dev/null; then
    mpstat -P ALL 1 1 2>/dev/null | awk '/^[0-9]/ || /^Average:/ && !/all/' | \
        tail -n +2 | grep -v "all" | \
        awk '{print $2, 100-$NF}' | \
        sort -k2 -rn | head -n "$TOP_N" | \
        awk '{printf "${color6}Core %2d${color} %5.1f%%  ", $1, $2}'
else
    # Fallback: read /proc/stat twice
    declare -A prev_total prev_idle

    while read -r line; do
        if [[ $line =~ ^cpu([0-9]+) ]]; then
            core=${BASH_REMATCH[1]}
            read -r _ user nice system idle iowait irq softirq <<< "$line"
            total=$((user + nice + system + idle + iowait + irq + softirq))
            prev_total[$core]=$total
            prev_idle[$core]=$idle
        fi
    done < /proc/stat

    sleep 1

    declare -A usage
    while read -r line; do
        if [[ $line =~ ^cpu([0-9]+) ]]; then
            core=${BASH_REMATCH[1]}
            read -r _ user nice system idle iowait irq softirq <<< "$line"
            total=$((user + nice + system + idle + iowait + irq + softirq))
            diff_total=$((total - prev_total[$core]))
            diff_idle=$((idle - prev_idle[$core]))
            if ((diff_total > 0)); then
                usage[$core]=$(( (diff_total - diff_idle) * 100 / diff_total ))
            else
                usage[$core]=0
            fi
        fi
    done < /proc/stat

    # Sort and show top N
    for core in "${!usage[@]}"; do
        echo "$core ${usage[$core]}"
    done | sort -k2 -rn | head -n "$TOP_N" | \
        awk '{printf "${color6}Core %2d${color} %3d%%  ", $1, $2}'
fi

echo ""
