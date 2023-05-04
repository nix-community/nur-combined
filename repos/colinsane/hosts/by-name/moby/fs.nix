{ ... }:

{
  sane.persist.root-on-tmpfs = true;
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1f1271f8-53ce-4081-8a29-60a4a6b5d6f9";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0299-F1E5";
    fsType = "vfat";
  };
}
