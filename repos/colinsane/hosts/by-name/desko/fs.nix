{ ... }:

{
  # increase /tmp space (defaults to 50% of RAM) for building large nix things.
  # a cross-compiled kernel, particularly, will easily use 30+GB of tmp
  fileSystems."/tmp".options = [ "size=64G" ];

  fileSystems."/nix" = {
    # device = "/dev/disk/by-uuid/985a0a32-da52-4043-9df7-615adec2e4ff";
    device = "/dev/disk/by-uuid/0ab0770b-7734-4167-88d9-6e4e20bb2a56";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    # device = "/dev/disk/by-uuid/CAA7-E7D2";
    device = "/dev/disk/by-uuid/41B6-BAEF";
    fsType = "vfat";
  };
}
