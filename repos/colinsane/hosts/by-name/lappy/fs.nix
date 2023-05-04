{ ... }:

{
  sane.persist.root-on-tmpfs = true;
  # we need a /tmp of default size (half RAM) for building large nix things
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "mode=777"
      "defaults"
    ];
  };

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

  # fileSystems."/nix" = {
  #   device = "/dev/disk/by-uuid/5a7fa69c-9394-8144-a74c-6726048b129f";
  #   fsType = "btrfs";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/4302-1685";
  #   fsType = "vfat";
  # };

  # fileSystems."/" = {
  #   device = "none";
  #   fsType = "tmpfs";
  #   options = [
  #     "mode=755"
  #     "size=1G"
  #     "defaults"
  #   ];
  # };
}
