{
  config,
  inputs,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader.grub = {
      device = "/dev/vda";
      configurationLimit = 3;
    };
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "xen_blkfront"
        "vmw_pvscsi"
      ];
      kernelModules = [ "nvme" ];

      systemd.enable = true;
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];

    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "audit=0"
      "net.ifnames=0"

      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
    ];

    kernelModules = [ "brutal" ];
    extraModulePackages = with config.boot.kernelPackages; [
      (callPackage "${inputs.self}/pkgs/kernel-module/tcp-brutal/package.nix" { })
    ];
  };
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "btrfs";
    options = [
      "compress-force=zstd:4"
      "noatime"
    ];
    neededForBoot = true;
  };
  # Auto enabled boot.loader.grub.copyKernels
  fileSystems."/boot" = {
    device = "/dev/vda3";
    fsType = "vfat";
  };
}
