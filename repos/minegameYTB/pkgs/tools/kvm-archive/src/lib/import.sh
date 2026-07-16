cmd_import() {
  local archive_path=""
  local target_pool="$DEFAULT_POOL"
  local new_vm_name=""
  local zfs_pool=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pool)
        shift
        target_pool="${1:-}"
        [[ -z "$target_pool" ]] && die "--pool requires a pool name."
        ;;
      --name)
        shift
        new_vm_name="${1:-}"
        [[ -z "$new_vm_name" ]] && die "--name requires a VM name."
        ;;
      --zfs-pool)
        shift
        zfs_pool="${1:-}"
        [[ -z "$zfs_pool" ]] && die "--zfs-pool requires a pool name."
        ;;
      -*) die "Unknown option: $1" ;;
      *)  archive_path="$1" ;;
    esac
    shift
  done

  [[ -z "$archive_path" ]] && die "Usage: $SCRIPT_NAME import <archive.tar.gz|xz|zst> [--pool <pool_name>] [--name <new_name>]"
  [[ -f "$archive_path" ]]  || die "Archive not found: $archive_path"

  log_section "Importing from: $archive_path"

  local pool_path
  pool_path="$(virsh pool-dumpxml "$target_pool" 2>/dev/null \
    | grep '<path>' | sed 's|.*<path>\(.*\)</path>.*|\1|' | xargs)" \
    || die "Pool '$target_pool' not found. Check with: virsh pool-list --all"
  [[ -d "$pool_path" ]] || die "Pool directory '$pool_path' does not exist."

  local archive_dir work_dir
  archive_dir="$(dirname "$archive_path")"
  work_dir="$(mktemp -d "${archive_dir}/.kvm-import-work-XXXXXX")"
  local zfs_cleanup=""
  trap 'rm -rf "$work_dir"; for __z in $zfs_cleanup; do zfs destroy -r "$__z" 2>/dev/null || true; done' EXIT

  log_info "Extracting archive..."
  local arc_size
  arc_size="$(du -sb "$archive_path" | cut -f1)"

  case "$archive_path" in
    *.tar.gz)  pv -s "$arc_size" -N "extracting (gz)"  "$archive_path" | tar -xzf - -C "$work_dir" ;;
    *.tar.xz)  pv -s "$arc_size" -N "extracting (xz)"  "$archive_path" | tar -xJf - -C "$work_dir" ;;
    *.tar.zst) zstd -d --progress "$archive_path" -c | tar -xf - -C "$work_dir" ;;
    *) die "Unsupported archive format. Expected .tar.gz, .tar.xz or .tar.zst" ;;
  esac || die "Failed to extract archive."

  local vm_dir
  vm_dir="$(find "$work_dir" -mindepth 1 -maxdepth 1 -type d | head -n1)"
  [[ -d "$vm_dir" ]] || die "Invalid archive structure: no directory found."

  local xml_file="${vm_dir}/vm.xml"
  local index_file="${vm_dir}/disk_index.txt"
  local disks_dir="${vm_dir}/disks"

  [[ -f "$xml_file" ]] || die "vm.xml not found in archive."

  local vm_name original_vm_name
  vm_name="$(grep -oP '(?<=<name>)[^<]+' "$xml_file" | head -n1)"
  [[ -z "$vm_name" ]] && die "Cannot read VM name from vm.xml."

  original_vm_name="$vm_name"
  log_info "Detected VM name: $vm_name"

  if [[ -n "$new_vm_name" ]]; then
    log_info "Renaming VM: $vm_name → $new_vm_name"
    sed -i "s|<name>${vm_name}</name>|<name>${new_vm_name}</name>|g" "$xml_file"
    vm_name="$new_vm_name"
  fi

  vm_exists "$vm_name" && die "A VM named '$vm_name' already exists. Remove or rename it first."

  if [[ -f "$index_file" ]]; then
    log_info "Restoring disks to pool '$target_pool' ($pool_path)..."

    while IFS='|' read -r original_path disk_filename disk_format zfs_dataset zfs_snapshot zfs_volsize; do
      local src_disk="${disks_dir}/${disk_filename}"

      if [[ "$disk_format" == "zfs" ]]; then
        if command -v zfs &>/dev/null; then
          [[ ! -f "$src_disk" ]] && { log_warn "ZFS stream missing: $disk_filename — skipping."; continue; }

          local target_dataset="$zfs_dataset"

          if [[ -n "$zfs_pool" ]]; then
            local zvol_name="${target_dataset##*/}"
            target_dataset="${zfs_pool}/${zvol_name}"
          fi

          local pool="${target_dataset%%/*}"

          if [[ -n "$new_vm_name" ]]; then
            target_dataset="${target_dataset/$original_vm_name/$new_vm_name}"
          fi

          log_info "Restoring ZFS dataset: $target_dataset"

          local temp_parent="kvm-import-tmp-${TIMESTAMP}"
          if ! zfs create -p "${pool}/${temp_parent}" 2>/dev/null; then
            log_error "Failed to create temporary ZFS dataset. Is pool '$pool' available?"
            die "ZFS pool '$pool' may need to be imported first."
          fi
          zfs_cleanup="$zfs_cleanup ${pool}/${temp_parent}"

          if ! zfs receive -F -d "${pool}/${temp_parent}" < "$src_disk" 2>/dev/null; then
            zfs destroy -r "${pool}/${temp_parent}" 2>/dev/null || true
            die "Failed to receive ZFS stream for '$disk_filename'."
          fi

          local received_dataset="${pool}/${temp_parent}/${zfs_dataset#*/}"

          local final_parent="${target_dataset%/*}"
          if [[ "$final_parent" != "$target_dataset" ]]; then
            zfs create -p "$final_parent" 2>/dev/null || true
          fi

          if ! zfs rename "$received_dataset" "$target_dataset" 2>/dev/null; then
            zfs destroy -r "${pool}/${temp_parent}" 2>/dev/null || true
            die "Failed to rename dataset to '$target_dataset'."
          fi

          zfs destroy -r "${pool}/${temp_parent}" 2>/dev/null \
            || log_warn "Could not clean up temporary dataset '${pool}/${temp_parent}'."

          # Remove the transport snapshot (only needed for zfs send/receive)
          if [[ -n "$zfs_snapshot" ]]; then
            zfs destroy "${target_dataset}@${zfs_snapshot}" 2>/dev/null \
              || log_warn "Could not remove temporary snapshot ${zfs_snapshot}."
          fi

          local new_dev_path="/dev/zvol/${target_dataset}"
          if [[ "$original_path" != "$new_dev_path" ]]; then
            log_info "Updating path in vm.xml: $original_path → $new_dev_path"
            sed -i "s|${original_path}|${new_dev_path}|g" "$xml_file"
          fi

          log_ok "Zvol restored: $target_dataset"
        else
          log_warn "'zfs' command not found. Cannot restore zvol '$disk_filename'. Skipping."
        fi
        continue
      fi

      local dest_filename="$disk_filename"
      if [[ -n "$new_vm_name" ]]; then
        dest_filename="${disk_filename/$original_vm_name/$new_vm_name}"
      fi

      local dest_disk="${pool_path}/${dest_filename}"

      if [[ ! -f "$src_disk" ]]; then
        log_warn "Disk missing in archive: $disk_filename — skipping."
        continue
      fi

      log_info "Restoring: $disk_filename → $dest_filename (format: $disk_format)..."
      qemu-img convert -O "$disk_format" -p \
        "$src_disk" "$dest_disk" \
        || die "Failed to restore disk '$disk_filename'."

      log_ok "Disk restored: $dest_disk"

      if [[ "$original_path" != "$dest_disk" ]]; then
        log_info "Updating path in vm.xml: $original_path → $dest_disk"
        sed -i "s|${original_path}|${dest_disk}|g" "$xml_file"
      fi

    done < "$index_file"

    virsh pool-refresh "$target_pool" &>/dev/null || true

  else
    log_warn "No disk index found — importing XML definition only."
  fi

  sed -i '/<uuid>/d' "$xml_file"
  log_info "Defining VM in libvirt..."
  virsh define "$xml_file" \
    || die "Failed to define VM. Check vm.xml manually."

  log_section "Import complete"
  log_ok "VM '$vm_name' imported successfully."
  log_info "Start it with: virsh start $vm_name"
  log_info "Or open virt-manager."

  trap - EXIT
  rm -rf "$work_dir"
}
