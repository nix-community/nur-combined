{ ... }:

{
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/75230e56-2c69-4e41-b03e-68475f119980";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BD79-D6BB";
    fsType = "vfat";
  };
}
