{ ... }:

{
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/cccccccc-aaaa-dddd-eeee-000020251021";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2025-1021";
    fsType = "vfat";
  };
}
