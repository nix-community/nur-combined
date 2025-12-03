{
  config,
  pkgs,
  inputs,
  vaculib,
  ...
}:
let
  commonBtrfsOpts = [
    "compress=zstd:5"
    "datacow"
    "datasum"
    "discard=async"
    "ssd_spread"
    "noatime"
    "fatal_errors=panic"
  ];
  btrfs-progs = pkgs.btrfs-progs;
  btrfs = "${btrfs-progs}/bin/btrfs";
  btrfsDevice = config.disko.devices.disk.root.device;
in
{
  imports = [ inputs.disko.nixosModules.default ];
  disko = {
    enableConfig = true;
    checkScripts = true;

    devices.disk.root = {
      type = "disk";
      device = "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00005";

      content = {
        type = "table";

        format = "msdos";
        partitions = [
          {
            name = "main";
            fs-type = "btrfs";
            start = "2M";
            bootable = true;
            content = {
              type = "btrfs";
              mountpoint = "/btr-root-in-here/btr-root";
              mountOptions = [
                "ro"
                "X-mount.mkdir=0700"
              ]
              ++ commonBtrfsOpts;
              subvolumes.root = {
                mountpoint = "/";
                mountOptions = commonBtrfsOpts;
              };
              subvolumes.persistent = {
                mountpoint = "/persistent";
                mountOptions = commonBtrfsOpts;
              };
              subvolumes.persistent-cache = {
                mountpoint = "/persistent-cache";
                mountOptions = commonBtrfsOpts;
              };
              subvolumes.big-tmp = {
                mountpoint = "/tmp";
                mountOptions = commonBtrfsOpts;
              };
              subvolumes.nix = {
                mountpoint = "/nix";
                mountOptions = commonBtrfsOpts;
              };
            };
          }
        ];
      };
    };
    devices.disk.storage = {
      type = "disk";
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";

      content = {
        type = "gpt";
        partitions.root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/xstore";
            mountOptions = [ "nofail" ];
          };
        };
      };
    };
  };

  fileSystems."/persistent".neededForBoot = true;
  fileSystems."/persistent-cache".neededForBoot = true;

  boot.loader.grub.devices = [ config.disko.devices.disk.root.device ];

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

  systemd.tmpfiles.settings."10-vacu"."/btr-root-in-here".d = {
    user = "root";
    group = "root";
    mode = vaculib.accessModeStr { user = "all"; };
  };

  fileSystems."/btr-root-in-here/ro" = {
    device = btrfsDevice + "-part1";
    fsType = "btrfs";
    options = [ "ro" "nofail" ] ++ commonBtrfsOpts;
  };

  fileSystems."/btr-root-in-here/rw" = {
    device = btrfsDevice + "-part1";
    fsType = "btrfs";
    options = [
      "noauto"
      "nofail"
    ]
    ++ commonBtrfsOpts;
  };
}
