{ ... }:

{
  sane.persist.root-on-tmpfs = true;
  # we need a /tmp for building large nix things
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "mode=777"
      "defaults"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/cc81cca0-3cc7-4d82-a00c-6243af3e7776";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6EE3-4171";
    fsType = "vfat";
  };

  # slow, external storage (for archiving, etc)
  fileSystems."/mnt/persist/ext" = {
    device = "/dev/disk/by-uuid/aa272cff-0fcc-498e-a4cb-0d95fb60631b";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  sane.persist.stores."ext" = {
    origin = "/mnt/persist/ext/persist";
    storeDescription = "external HDD storage";
  };
  sane.fs."/mnt/persist/ext".mount = {};

  sane.persist.sys.plaintext = [
    # TODO: this is overly broad; only need media and share directories to be persisted
    { user = "colin"; group = "users"; directory = "/var/lib/uninsane"; }
  ];
  # make sure large media is stored to the HDD
  sane.persist.sys.ext = [
    {
      user = "colin";
      group = "users";
      mode = "0777";
      directory = "/var/lib/uninsane/media/Videos";
    }
    {
      user = "colin";
      group = "users";
      mode = "0777";
      directory = "/var/lib/uninsane/media/freeleech";
    }
  ];

  # in-memory compressed RAM (seems to be dynamically sized)
  # zramSwap = {
  #   enable = true;
  # };

  # btrfs doesn't easily support swapfiles
  # swapDevices = [
  #   { device = "/nix/persist/swapfile"; size = 4096; }
  # ];

  # this can be a partition. create with:
  #   fdisk <dev>
  #     n
  #     <default partno>
  #     <start>
  #     <end>
  #     t
  #     <partno>
  #     19  # set part type to Linux swap
  #     w   # write changes
  #   mkswap -L swap <part>
  # swapDevices = [
  #   {
  #     label = "swap";
  #     # TODO: randomEncryption.enable = true;
  #   }
  # ];
}

