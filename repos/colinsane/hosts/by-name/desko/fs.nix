{ ... }:

{
  # increase /tmp space (defaults to 50% of RAM) for building large nix things.
  # a cross-compiled kernel, particularly, will easily use 30+GB of tmp
  fileSystems."/tmp".options = [ "size=64G" ];

  fileSystems."/nix" = {
    # device = "/dev/disk/by-uuid/0ab0770b-7734-4167-88d9-6e4e20bb2a56";
    device = "/dev/disk/by-uuid/845d85bf-761d-431b-a406-e6f20909154f";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    # device = "/dev/disk/by-uuid/41B6-BAEF";
    device = "/dev/disk/by-uuid/5049-9AFD";
    fsType = "vfat";
  };
}
