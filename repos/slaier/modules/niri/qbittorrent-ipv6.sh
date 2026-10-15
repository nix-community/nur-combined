#!/usr/bin/env bash
# Set qBittorrent Session\InterfaceAddress to a private IPv6 temporary address
# (falls back to IPv4) before launching qbittorrent.
set -u

conf="${XDG_CONFIG_HOME:-$HOME/.config}/qBittorrent/qBittorrent.conf"

dev=$(ip -4 route show default | awk 'NR == 1 { print $5 }')
addr=""
if [ -n "$dev" ]; then
  addr=$(ip -6 addr show dev "$dev" scope global | awk '/inet6/ && !/deprecated/ && /temporary/ { split($2, a, "/"); print a[1]; exit }')
  [ -z "$addr" ] && addr=$(ip -6 addr show dev "$dev" scope global | awk '/inet6/ && !/deprecated/ { split($2, a, "/"); print a[1]; exit }')
  [ -z "$addr" ] && addr=$(ip -4 addr show dev "$dev" scope global | awk '/inet / { split($2, a, "/"); print a[1]; exit }')
fi

if [ -n "$addr" ] && [ -f "$conf" ] && grep -q '^Session\\InterfaceAddress=' "$conf"; then
  sed -i "s|^Session\\\\InterfaceAddress=.*|Session\\\\InterfaceAddress=$addr|" "$conf"
fi

exec qbittorrent "$@"
