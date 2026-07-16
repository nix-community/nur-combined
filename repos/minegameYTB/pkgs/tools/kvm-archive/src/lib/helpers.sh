# Always inject the URI into every virsh call
virsh() { command virsh -c "$VIRSH_URI" "$@"; }

# Dump VM XML definition
get_vm_xml() {
  virsh dumpxml "$1" 2>/dev/null \
    || die "Cannot get XML for VM '$1'. Does it exist?"
}

# Returns true if VM exists (any state)
vm_exists() {
  virsh dominfo "$1" &>/dev/null
}

# Returns current VM state: running, shut off, paused, etc.
get_vm_state() {
  virsh domstate "$1" 2>/dev/null | tr -d ' '
}

# List disk image paths for a VM (excludes cdroms)
get_disk_paths() {
  virsh domblklist "$1" --details \
    | awk '$2 == "disk" && $4 != "-" { print $4 }'
}
