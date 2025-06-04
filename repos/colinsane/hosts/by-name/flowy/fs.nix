{ ... }:

{
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/ffffffff-1111-0000-eeee-000020250531";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2025-0531";
    fsType = "vfat";
  };
}
