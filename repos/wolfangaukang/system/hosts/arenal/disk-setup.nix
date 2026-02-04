{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Extra options to filesystem
  fileSystems =
    let
      bootSettings = {
        neededForBoot = true;
        options = [
          "defaults"
          "ssd"
          "compress=zstd"
          "noatime"
          "discard=async"
          "space_cache=v2"
        ];
      };

    in
    {
      "/".options = [
        "defaults"
        "size=25%"
        "mode=755"
      ];
      "/nix" = bootSettings;
      "/mnt/persist" = bootSettings;
    };
  services.btrfs.autoScrub.enable = true;
  boot = {
    initrd = {
      luks.devices."root" = {
        allowDiscards = true;
        keyFile = "/keyfile0.bin";
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    # /tmp settings
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}
