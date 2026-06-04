{ utils, ... }:

let
  inherit (utils) escapeSystemdPath;
in
{
  # zswap
  boot.zswap.enable = true;

  # Disks
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
  };

  # TRIM
  systemd.services.fstrim.unitConfig.ConditionACPower = true;

  # LVM on LUKS
  boot.initrd.luks = {
    devices.pv = {
      device = "/dev/disk/by-partlabel/pv-enc";
      allowDiscards = true;
    };
  };

  # /
  fileSystems."/".options = [
    "compress=zstd:2"
    "discard=async"
    "noatime"
    "x-systemd.device-timeout=infinity" # Await LUKS prompt
  ];
  services.btrfs.autoScrub.enable = true;
  systemd.services."btrfs-scrub-${escapeSystemdPath "/"}".unitConfig.ConditionACPower = true;
  security.sudo.allowedCommands = [ "/run/current-system/sw/bin/btrfs balance start --enqueue -dusage=50 -musage=50 /" ];

  # /boot
  fileSystems."/boot".options = [ "umask=0077" ]; #  NixOS/nixpkgs#279362

  # /dev/shm
  boot.specialFileSystems."/dev/shm".options = [ "noexec" ];

  # /tmp
  boot.tmp.cleanOnBoot = true;
}
