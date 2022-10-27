{ ... }:

{
  boot = {
    initrd = {
      luks.devices."root" = {
        allowDiscards = true;
        device = "/dev/disk/by-uuid/37b3f7d6-00eb-4cd3-90b0-5549bf6e48ce";
        keyFile = "/keyfile0.bin";
        preLVM = true;
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
    tmpOnTmpfs = true;
    cleanTmpDir = true;
  };
}
