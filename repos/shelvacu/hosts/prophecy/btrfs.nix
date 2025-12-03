{ pkgs, vaculib, ... }:
let
  btrfs-progs = pkgs.btrfs-progs;
  btrfs = "${btrfs-progs}/bin/btrfs";
  btrfsDevice = "/dev/mapper/prophecy-root-decrypted";
  btrfsOpts = [
    "compress=zstd:2"
    "datacow"
    "datasum"
    "discard=async"
    "ssd_spread"
    "noatime"
    "fatal_errors=panic"
  ];
in
{
  fileSystems."/" = {
    device = btrfsDevice;
    fsType = "btrfs";
    options = [ "subvol=root" ] ++ btrfsOpts;
  };

  systemd.tmpfiles.settings."10-vacu"."/btr-root-in-here".d = {
    user = "root";
    group = "root";
    mode = vaculib.accessModeStr { user = "all"; };
  };

  fileSystems."/btr-root-in-here/ro" = {
    device = btrfsDevice;
    fsType = "btrfs";
    options = [ "ro" ] ++ btrfsOpts;
  };

  fileSystems."/btr-root-in-here/rw" = {
    device = btrfsDevice;
    fsType = "btrfs";
    options = [
      "noauto"
      "nofail"
    ]
    ++ btrfsOpts;
  };

  boot.initrd.systemd.services."vacu-impermanence-setup" = {
    enable = true;
    wantedBy = [ "initrd-root-device.target" ];
    before = [
      "sysroot.mount"
      "create-needed-for-boot-dirs.service"
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      btrfs_tmp="$(mktemp -d)"
      mount ${btrfsDevice} "$btrfs_tmp"
      (
        cd "$btrfs_tmp"
        if [[ -e root ]]; then
          mkdir -p old_roots
          timestamp=$(date --date="@$(stat -c %Y root)" "+%Y-%m-%d_%H:%M:%S")
          mv root "old_roots/$timestamp"
        fi
        btrfs subvolume create ./root

        btrfs subvolume delete ./big-tmp
        btrfs subvolume create ./big-tmp
      )
      umount "$btrfs_tmp"
      rmdir "$btrfs_tmp"
    '';
  };

  vacu.packages = [
    btrfs-progs
    (pkgs.writeScriptBin "delete_old_root" ''
      set -euo pipefail
      timestamp="$1"
      shift
      if [[ -z "$timestamp" ]]; then
        echo "missing arg" >&2
        exit 1
      fi
      mntpoint="$(mktemp -d)"
      mount -t btrfs ${btrfsDevice} "$mntpoint"
      full_path="$mntpoint/old_roots/$timestamp"

      if ! [[ -d "$full_path" ]]; then
        echo "couldnt find subvol old_roots/$timestamp" >&2
        exit 1
      fi

      ${btrfs} subvolume delete -R "$full_path"
    '')
  ];

  # back me up, scotty
  fileSystems."/persistent" = {
    device = btrfsDevice;
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persistent" ] ++ btrfsOpts;
  };

  # keep me around, but no need to back me up
  fileSystems."/persistent-cache" = {
    device = btrfsDevice;
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persistent-cache" ] ++ btrfsOpts;
  };

  # deleted and re-created on every boot, for stuff too big to go in a tmpfs
  fileSystems."/tmp" = {
    device = btrfsDevice;
    fsType = "btrfs";
    options = [ "subvol=big-tmp" ] ++ btrfsOpts;
  };

  fileSystems."/nix" = {
    device = btrfsDevice;
    fsType = "btrfs";
    options = [ "subvol=nix" ] ++ btrfsOpts;
  };
}
