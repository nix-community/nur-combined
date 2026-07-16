cmd_export() {
  local vm_name=""
  local dest_dir="$DEFAULT_EXPORT_DIR"
  local compress_fmt="$DEFAULT_FORMAT"
  local compress_level="$DEFAULT_LEVEL"

  local positional=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format)
        shift
        compress_fmt="${1:-}"
        [[ "$compress_fmt" =~ ^(gz|xz|zst)$ ]] || die "--format must be gz, xz or zst."
        ;;
      --level)
        shift
        compress_level="${1:-}"
        [[ "$compress_level" =~ ^[1-9]$ ]] || die "--level must be between 1 and 9."
        ;;
      -*)
        die "Unknown option: $1"
        ;;
      *)
        if [[ $positional -eq 0 ]]; then
          vm_name="$1"
        elif [[ $positional -eq 1 ]]; then
          dest_dir="$1"
        fi
        positional=$((positional + 1))
        ;;
    esac
    shift
  done

  [[ -z "$vm_name" ]] && die "Usage: $SCRIPT_NAME export <vm_name> [destination_dir] [--format gz|xz|zst] [--level 1-9]"

  log_section "Exporting VM: $vm_name"

  vm_exists "$vm_name" || die "VM '$vm_name' not found."
  mkdir -p "$dest_dir"  || die "Cannot create directory '$dest_dir'."

  local archive_name="${vm_name}_${TIMESTAMP}"

  local work_dir="${dest_dir}/.kvm-archive-work-${archive_name}"
  mkdir -p "$work_dir" || die "Cannot create work directory in '$dest_dir'."
  local zfs_cleanup=""
  trap 'rm -rf "$work_dir"; for __z in $zfs_cleanup; do zfs destroy "$__z" 2>/dev/null || true; done' EXIT

  local vm_dir="${work_dir}/${archive_name}"
  mkdir -p "$vm_dir"

  log_info "Saving XML definition..."
  get_vm_xml "$vm_name" > "${vm_dir}/vm.xml"
  log_ok "XML saved."

  local initial_state was_running=false
  initial_state="$(get_vm_state "$vm_name")"

  if [[ "$initial_state" == "running" ]]; then
    log_warn "VM is running — sending shutdown..."
    virsh shutdown "$vm_name" || die "Failed to shutdown VM."

    local timeout=60
    while [[ "$(get_vm_state "$vm_name")" != "shutoff" ]]; do
      sleep 2
      timeout=$((timeout - 2))
      if [[ $timeout -le 0 ]]; then
        log_warn "Timeout reached — forcing destroy..."
        virsh destroy "$vm_name" || die "Failed to force stop VM."
        break
      fi
    done
    was_running=true
    log_ok "VM stopped."
  fi

  log_info "Collecting disk paths..."
  local disks
  mapfile -t disks < <(get_disk_paths "$vm_name")

  [[ ${#disks[@]} -eq 0 ]] && log_warn "No disks found — archive will contain XML only."

  local disks_dir="${vm_dir}/disks"
  mkdir -p "$disks_dir"

  local index_file="${vm_dir}/disk_index.txt"
  : > "$index_file"

  for disk_path in "${disks[@]}"; do
    local disk_format="" disk_filename=""

    if is_zvol_path "$disk_path"; then
      if command -v zfs &>/dev/null; then
        local zfs_dataset zfs_volsize snapshot_name
        zfs_dataset="$(get_zvol_dataset "$disk_path")"
        zfs_volsize="$(get_zvol_size "$zfs_dataset")"
        snapshot_name="kvm-archive-${TIMESTAMP}"

        log_info "Creating ZFS snapshot: ${zfs_dataset}@${snapshot_name}..."
        zfs snapshot "${zfs_dataset}@${snapshot_name}" \
          || die "Failed to create ZFS snapshot for '$zfs_dataset'."
        zfs_cleanup="$zfs_cleanup ${zfs_dataset}@${snapshot_name}"

        local disk_basename
        disk_basename="$(basename "$disk_path")"
        disk_filename="${disk_basename}.zfs"
        log_info "Saving ZFS stream to: ${disk_filename}..."
        if ! zfs send "${zfs_dataset}@${snapshot_name}" > "${disks_dir}/${disk_filename}"; then
          zfs destroy "${zfs_dataset}@${snapshot_name}" 2>/dev/null || true
          die "Failed to send ZFS snapshot '$zfs_dataset'."
        fi

        zfs destroy "${zfs_dataset}@${snapshot_name}" 2>/dev/null \
          || log_warn "Could not destroy temporary snapshot ${snapshot_name}."

        disk_format="zfs"
        echo "${disk_path}|${disk_filename}|${disk_format}|${zfs_dataset}|${snapshot_name}|${zfs_volsize}" >> "$index_file"
        log_ok "Zvol saved: $disk_path (dataset: $zfs_dataset)"
      else
        log_warn "'zfs' command not found. Falling back to qemu-img convert for zvol: $disk_path"
        if [[ ! -b "$disk_path" ]]; then
          log_warn "Block device not found, skipping: $disk_path"
          continue
        fi
        disk_format="$(qemu-img info "$disk_path" 2>/dev/null | awk -F': ' '/^file format:/ { print $2 }')"
        disk_format="${disk_format:-raw}"
        disk_filename="$(basename "$disk_path")"

        log_info "Copying zvol (fallback): $disk_path (format: $disk_format)..."
        qemu-img convert -O "$disk_format" -p \
          "$disk_path" \
          "${disks_dir}/${disk_filename}" \
          || die "Failed to copy zvol '$disk_path'."

        echo "${disk_path}|${disk_filename}|${disk_format}" >> "$index_file"
        log_ok "Zvol copied (fallback): $disk_filename"
      fi
      continue
    fi

    if [[ ! -f "$disk_path" ]]; then
      log_warn "Disk not found, skipping: $disk_path"
      continue
    fi

    disk_format="$(qemu-img info "$disk_path" | awk -F': ' '/^file format:/ { print $2 }')"
    disk_filename="$(basename "$disk_path")"

    log_info "Copying disk: $disk_path (format: $disk_format)..."
    qemu-img convert -O "$disk_format" -p \
      "$disk_path" \
      "${disks_dir}/${disk_filename}" \
      || die "Failed to copy disk '$disk_path'."

    echo "${disk_path}|${disk_filename}|${disk_format}" >> "$index_file"
    log_ok "Disk copied: $disk_filename"
  done

  local archive_path="${dest_dir}/${archive_name}.tar.${compress_fmt}"
  log_info "Creating archive: $archive_path (format: $compress_fmt, level: $compress_level)..."

  local tar_size
  tar_size="$(du -sb "${work_dir}/${archive_name}" | cut -f1)"

  case "$compress_fmt" in
    gz)  tar -cf - -C "$work_dir" "$archive_name"            | pv -s "$tar_size" -N "compressing (gz-${compress_level})"            | gzip -${compress_level} > "$archive_path" ;;
    xz)  tar -cf - -C "$work_dir" "$archive_name"            | pv -s "$tar_size" -N "compressing (xz-${compress_level})"            | xz -${compress_level} > "$archive_path" ;;
    zst) tar -cf - -C "$work_dir" "$archive_name" \
             | zstd -${compress_level} --progress -o "$archive_path" ;;
  esac || die "Failed to create archive."

  log_ok "Archive created: $archive_path"
  log_info "Size: $(du -sh "$archive_path" | cut -f1)"

  if [[ "$was_running" == true ]]; then
    log_info "Restarting VM (it was running before export)..."
    virsh start "$vm_name" && log_ok "VM restarted." \
      || log_warn "Could not restart VM automatically."
  fi

  log_section "Export complete"
  log_ok "VM '$vm_name' exported to: $archive_path"

  trap - EXIT
  rm -rf "$work_dir"
}
