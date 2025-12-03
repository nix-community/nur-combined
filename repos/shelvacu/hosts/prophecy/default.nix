{ vaculib, vacuModules, ... }:
{
  imports = [
    vacuModules.sops
    vacuModules.dyndns-powerhouse
    vacuModules.auto-oauth-proxy
  ]
  ++ (builtins.attrValues (vaculib.directoryGrabber { path = ./.; }));
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  # boot.initrd.systemd.services."debug-shell".wantedBy = [ "sysinit.target" ];

  vacu.hostName = "prophecy";
  vacu.shortHostName = "prop";
  vacu.shell.color = "green";
  vacu.verifySystem.expectedMac = "6c:02:e0:43:02:7a";
  vacu.systemKind = "server";
  networking.hostId = "f6236a3d";

  vacu.packages = ''
    sanoid
    httrack
  '';

  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  system.stateVersion = "24.11";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.mutableUsers = false;
  users.users.root.initialHashedPassword = "$2b$15$D66qIGBJm27pTuX1Rc6aeuQGcrX71T2Gxg.PmTYPAdOnDI1trCtqC";
  users.users.shelvacu.initialHashedPassword = "$2b$15$D66qIGBJm27pTuX1Rc6aeuQGcrX71T2Gxg.PmTYPAdOnDI1trCtqC";

  # a dummy user/group that I can set on folders to indicate that they shouldn't be touched
  users.users.archived = {
    # these are "sealed", "SEAL" = 5341
    uid = 5341;
    isSystemUser = true;
    group = "archived";
  };
  users.groups.archived.gid = 5341;

  environment.etc."nixos/flake.nix".source = "/home/shelvacu/dev/nix-stuff/flake.nix";

  # zfs can break with hibernate but takes no steps to warn/prevent this >:(
  boot.kernelParams = [ "nohibernate" ];
  boot.supportedFilesystems = [
    # nice to have for mounting disk images
    "zfs"
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

  networking.firewall.allowedTCPPorts = [ 5201 ]; # default port for iperf3

  # systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  systemd.enableStrictShellChecks = true;
}
