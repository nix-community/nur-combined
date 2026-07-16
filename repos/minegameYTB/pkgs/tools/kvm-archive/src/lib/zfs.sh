# Returns true if path is a ZFS zvol (/dev/zvol/…)
is_zvol_path() {
  [[ "$1" == /dev/zvol/* ]]
}

# Extract ZFS dataset name from a /dev/zvol/ path
#   /dev/zvol/tank/vms/myvm/disk0 → tank/vms/myvm/disk0
get_zvol_dataset() {
  echo "${1#/dev/zvol/}"
}

# Get volsize (bytes) for a ZFS zvol dataset
get_zvol_size() {
  zfs get -Hp volsize "$1" 2>/dev/null | awk '{print $3}' || echo "0"
}
