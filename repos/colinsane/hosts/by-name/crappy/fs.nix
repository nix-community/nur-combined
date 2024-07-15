{ ... }:
{
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/55555555-0303-0c12-86df-eda9e9311526";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/303C-5A37";
    fsType = "vfat";
  };
}
