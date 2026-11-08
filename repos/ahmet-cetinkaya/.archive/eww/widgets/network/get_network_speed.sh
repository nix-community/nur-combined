#!/bin/bash

iface=$(ip route | awk '/default/ { print $5; exit }')

if [ -z "$iface" ]; then
  echo "No network interface found."
  exit 1
fi

rx1=$(cat /sys/class/net/"$iface"/statistics/rx_bytes)
tx1=$(cat /sys/class/net/"$iface"/statistics/tx_bytes)

sleep 1

rx2=$(cat /sys/class/net/"$iface"/statistics/rx_bytes)
tx2=$(cat /sys/class/net/"$iface"/statistics/tx_bytes)

rx_diff=$((rx2 - rx1))
tx_diff=$((tx2 - tx1))

convert_rate() {
  local bytes=$1
  local bits=$((bytes * 8))
  local output

  if (( bits >= 1000000 )); then
    # MB/s
    output=$(awk -v b="$bits" 'BEGIN { printf "%.2f MB/s", b/1000000 }')
  else
    # KB/s (minimum)
    output=$(awk -v b="$bits" 'BEGIN { printf "%.2f KB/s", b/1000 }')
  fi

  # If value is zero-like, convert to integer 0
  if [[ "$output" =~ ^0+\.0+ ]]; then
    echo "0 ${output##* }"
  else
    echo "$output"
  fi
}

rx_human=$(convert_rate "$rx_diff")
tx_human=$(convert_rate "$tx_diff")

thin_space_character=$(printf '\u2009')

echo "↓$thin_space_character$rx_human ↑$thin_space_character$tx_human"