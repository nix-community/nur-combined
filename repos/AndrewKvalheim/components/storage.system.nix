{ config, lib, ... }:

let
  inherit (config.boot.kernel.sysfs.module) zswap;
  inherit (lib) escapeShellArg;

  identity = import ../library/identity.lib.nix { inherit lib; };
in
{
  # zswap (Pending NixOS/nixpkgs#470366)
  boot.initrd.kernelModules = with zswap.parameters; [ compressor zpool ];
  boot.kernelParams = with zswap.parameters; [
    "zswap.accept_threshold_percent=${toString accept_threshold_percent}"
    "zswap.compressor=${compressor}"
    "zswap.enabled=${if enabled then "1" else "0"}"
    "zswap.max_pool_percent=${toString max_pool_percent}"
    "zswap.shrinker_enabled=${if shrinker_enabled then "1" else "0"}"
    "zswap.zpool=${zpool}"
  ];
  boot.kernel.sysfs.module.zswap.parameters = {
    accept_threshold_percent = 90;
    compressor = "zstd";
    enabled = true;
    max_pool_percent = 25;
    shrinker_enabled = true;
    zpool = "zsmalloc";
  };

  # Disks
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
  };

  # TRIM
  systemd.services.fstrim.unitConfig.ConditionACPower = true;

  # LVM on LUKS
  boot.initrd.luks = {
    gpgSupport = true;
    devices.pv = {
      device = "/dev/disk/by-partlabel/pv-enc";
      allowDiscards = true;
      fallbackToPassword = true;
      gpgCard.encryptedPass = ./assets/luks-passphrase.local.gpg;
      gpgCard.publicKey = identity.openpgp.asc;
      preOpenCommands = "echo $'\n'${escapeShellArg identity.contactNotice}";
    };
  };

  # /
  fileSystems."/".options = [ "compress=zstd:2" "discard=async" "noatime" ];
  services.btrfs.autoScrub.enable = true;
  security.sudo.allowedCommands = [ "/run/current-system/sw/bin/btrfs balance start --enqueue -dusage=50 -musage=50 /" ];

  # /boot
  fileSystems."/boot".options = [ "umask=0077" ]; #  NixOS/nixpkgs#279362

  # /dev/shm
  boot.specialFileSystems."/dev/shm".options = [ "noexec" ];

  # /tmp
  boot.tmp.cleanOnBoot = true;
}
