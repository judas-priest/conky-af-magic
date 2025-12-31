#!/bin/bash
#
# Show top N most loaded CPU cores
#

TOP_N="${1:-8}"

# Read CPU stats twice with 1 second interval
get_cpu_stats() {
    grep '^cpu[0-9]' /proc/stat | while read -r line; do
        core=$(echo "$line" | awk '{print $1}' | sed 's/cpu//')
        stats=$(echo "$line" | awk '{print $2,$3,$4,$5,$6,$7,$8}')
        echo "$core $stats"
    done
}

# First reading
declare -A prev_stats
while read -r core user nice system idle iowait irq softirq; do
    prev_stats[$core]="$user $nice $system $idle $iowait $irq $softirq"
done <<< "$(get_cpu_stats)"

sleep 1

# Second reading and calculate usage
{
while read -r core user nice system idle iowait irq softirq; do
    read -r p_user p_nice p_system p_idle p_iowait p_irq p_softirq <<< "${prev_stats[$core]}"

    prev_total=$((p_user + p_nice + p_system + p_idle + p_iowait + p_irq + p_softirq))
    curr_total=$((user + nice + system + idle + iowait + irq + softirq))

    diff_total=$((curr_total - prev_total))
    diff_idle=$((idle - p_idle))

    if ((diff_total > 0)); then
        usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
    else
        usage=0
    fi

    echo "$core $usage"
done <<< "$(get_cpu_stats)"
} | sort -k2 -rn | head -n "$TOP_N" | \
    awk '{
        cores[NR] = $1
        usage[NR] = $2
    }
    END {
        for (i = 1; i <= NR; i += 2) {
            printf "${color6}#%d:${color} %3d%%", cores[i], usage[i]
            if (i+1 <= NR) {
                printf "${alignr}${color6}#%d:${color} %3d%%", cores[i+1], usage[i+1]
            }
            printf "\n"
        }
    }'
