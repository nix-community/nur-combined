#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# Use pciutils rather than the reduced lspci implementation in PATH.
pci_bin=""
if command -v setpci >/dev/null 2>&1; then
  pci_bin="$(dirname "$(command -v setpci)")"
else
  for candidate in /nix/store/*-pciutils-*/bin/setpci; do
    if [[ -x "$candidate" ]]; then
      pci_bin="${candidate%/setpci}"
      break
    fi
  done
fi
if [[ -z "$pci_bin" ]]; then
  printf 'pciutils is required; run this script in an environment with lspci and setpci.\n' >&2
  exit 1
fi

printf 'Kernel: '
uname -r
printf 'Boot ID: '
cat /proc/sys/kernel/random/boot_id
printf 'Booted system: '
readlink -f /run/booted-system
printf '\nKernel option:\n'
zcat /proc/config.gz | sed -n '/CONFIG_PCI_DYNAMIC_OF_NODES/p'

printf '\n$ lspci -nn\n'
"$pci_bin/lspci" -nn
printf '\n$ setpci -s 00:00.0 HEADER_TYPE\n'
"$pci_bin/setpci" -s 00:00.0 HEADER_TYPE
printf '\n$ setpci -s 00:00.0 PRIMARY_BUS SECONDARY_BUS SUBORDINATE_BUS\n'
"$pci_bin/setpci" -s 00:00.0 PRIMARY_BUS SECONDARY_BUS SUBORDINATE_BUS
printf '\nDriver: '
readlink -f /sys/bus/pci/devices/0000:00:00.0/driver
printf '\n00:00.0 of_node symlink: '
pci_of_node=""
if [[ -e /sys/bus/pci/devices/0000:00:00.0/of_node ]]; then
  pci_of_node="$(readlink -f /sys/bus/pci/devices/0000:00:00.0/of_node)"
  printf '%s\n' "$pci_of_node"
else
  printf 'absent\n'
  # A node added after device registration may have no of_node symlink.
  # This is the dynamic tree path for the device under test on goliath.
  pci_of_node=/sys/firmware/devicetree/base/pci@0,0/pci@0,0
fi
printf '\nOF node for 00:00.0 in the tree: '
if [[ -d "$pci_of_node" ]]; then
  printf '%s\n' "$pci_of_node"
  for property in device_type reg compatible bus-range interrupt-map; do
    printf '  %s: ' "$property"
    if [[ -f "$pci_of_node/$property" ]]; then
      if [[ "$property" == device_type ]]; then
        tr -d '\000' < "$pci_of_node/$property"
        printf '\n'
      elif [[ "$property" == compatible ]]; then
        tr '\000' '\n' < "$pci_of_node/$property"
      elif [[ "$property" == reg ]]; then
        od -An -tx1 "$pci_of_node/$property"
      else
        printf 'present (%s bytes)\n' "$(wc -c < "$pci_of_node/$property")"
      fi
    else
      printf 'absent\n'
    fi
  done
else
  printf 'absent\n'
fi
printf '\nKernel PCI buses:\n'
for bus in /sys/class/pci_bus/*; do
  printf '%s -> %s\n' "${bus##*/}" "$(readlink -f "$bus")"
done
printf '\nPCI OF debug messages and 00:00.0 boot messages:\n'
journalctl -k -b --no-pager -g 'PCI OF debug|0000:00:00.0' || true
printf '\nDynamic PCI OF nodes:\n'
if [[ -d /sys/firmware/devicetree/base ]]; then
  find /sys/firmware/devicetree/base -type d -name 'pci@*' -print
fi
