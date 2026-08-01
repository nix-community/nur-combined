#!/usr/bin/env bash

# --- CPU usage (sample /proc/stat twice over 0.2s) ---
read -r _ u1 n1 s1 i1 w1 x1 y1 z1 _ </proc/stat
sleep 0.2
read -r _ u2 n2 s2 i2 w2 x2 y2 z2 _ </proc/stat

idle1=$((i1 + w1))
idle2=$((i2 + w2))
busy1=$((u1 + n1 + s1 + x1 + y1 + z1))
busy2=$((u2 + n2 + s2 + x2 + y2 + z2))

tot1=$((idle1 + busy1))
tot2=$((idle2 + busy2))
dtot=$((tot2 - tot1))
didle=$((idle2 - idle1))

# add dtot/2 for rounding
cpu_usage=$((((dtot - didle) * 100 + dtot / 2) / dtot))

# --- RAM usage ---
# read total & used in MiB
{
    read -r _header
    read -r _ mem_total mem_used _
} < <(free -m)

mem_usage=$((mem_used * 100 / mem_total))

# read human-readable “used”
{
    read -r _header
    read -r _ _ used_h _
} < <(free -h)

# --- notify ---
dunstify -a "osd" -u low " CPU: ${cpu_usage}% |  RAM: ${mem_usage}% (${used_h})"
