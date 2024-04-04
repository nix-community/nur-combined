{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  zramSwap = {
    enable = true;
    swapDevices = 1;
    memoryPercent = 80;
    algorithm = "zstd";
  };

  boot = {
    loader.grub.device = "/dev/vda";
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "xen_blkfront"
        "vmw_pvscsi"
      ];
      kernelModules = [ "nvme" ];

      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;
    };

    tmp.cleanOnBoot = true;

    kernelParams = [
      "audit=0"
      "net.ifnames=0"
    ];

    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  # fileSystems."/persist".neededForBoot = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
