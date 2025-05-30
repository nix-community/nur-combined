{ ... }:

{
  # increase /tmp space (defaults to 50% of RAM) for building large nix things.
  # a cross-compiled kernel, particularly, will easily use 30+GB of tmp
  fileSystems."/tmp".options = [ "size=128G" ];

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/dddddddd-eeee-5555-cccc-000020250527";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2025-0527";
    fsType = "vfat";
  };
}
