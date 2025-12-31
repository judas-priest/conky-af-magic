#!/bin/bash
# Get display info with correct diagonal from hwinfo

hwinfo --monitor 2>/dev/null | awk '
/Model:/ {
    gsub(/"/, "", $0)
    model = $2
    for(i=3; i<=NF; i++) model = model " " $i
}
/Resolution:.*@/ {
    res = $2
}
/Size:/ {
    split($2, dims, "x")
    w = dims[1]
    h = dims[2]
    diag_mm = sqrt(w*w + h*h)
    diag_in = diag_mm / 25.4
    printf "%s: %s, %.0f\"\n", model, res, diag_in
}
'
