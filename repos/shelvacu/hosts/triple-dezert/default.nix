{
  config,
  pkgs,
  lib,
  vacuModules,
  ...
}:
{
  imports = [
    vacuModules.sops
    vacuModules.dyndns-powerhouse
    ./hardware-configuration.nix
    ./awootrip.nix
    ./database.nix
    #./vms.nix
    ./networking.nix
    ./emily.nix
    ./yt-archiver.nix
    ./proxied
    ./gallerygrab.nix
    # ./disko.nix
    ./docker.nix
    ./dovecot-backup.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #todo: increase boot partition size
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.memtest86.enable = true;
  # The first thing to complain was redis in the vacustore container:
  #
  #   WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. Being disabled, it can also cause failures without low memory condition, see https://github.com/jemalloc/jemalloc/issues/1328. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
  #
  # but I suspect other things will want it too
  boot.kernel.sysctl."vm.overcommit_memory" = "1";
  # systemctl in nixos-containers was borking because it couldn't create inotify instances, this seems to have fixed it:
  boot.kernel.sysctl."fs.inotify.max_user_instances" = "1024";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  vacu.hostName = "triple-dezert";
  vacu.shortHostName = "trip";
  vacu.shell.color = "yellow";
  vacu.verifySystem.expectedMac = "b8:ca:3a:68:15:c8";
  vacu.systemKind = "server";
  vacu.shell.containerAliases = true;

  services.xserver.enable = false;

  vacu.packages = lib.mkMerge [
    ''
      cryptsetup
      httrack
      openvpn
    ''
    [ config.services.postgresql.package ]
  ];

  hardware.graphics.extraPackages = [
    pkgs.intel-compute-runtime
    pkgs.ocl-icd
  ];

  services.openssh = {
    enable = true;
    # leaving port 22 available for gitea (or forgejo or whatever)
    ports = [ 6922 ];
  };

  system.stateVersion = "22.05";

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  # zfs can break with hibernate but takes no steps to warn/prevent this >:(
  boot.kernelParams = [
    "nohibernate"
    "panic=10" # on panic, reboot after 10s
  ];
  boot.supportedFilesystems = [
    "zfs" # needed to mount trip zfs pool
    # nice to have for mounting disk images
    "ntfs"
    "ext4"
    "btrfs"
    "f2fs"
    "xfs"
    "exfat"
    "vfat"
    "squashfs"
    "reiserfs"
    # "bcachefs"
    "unionfs-fuse"
    "jfs"
  ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "trip" ];
  networking.hostId = "c871875e";
  hardware.enableAllFirmware = true;
  nix.settings.auto-optimise-store = true;
}
