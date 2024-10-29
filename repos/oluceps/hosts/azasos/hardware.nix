{
  inputs,
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
    kernelModules = [ "brutal" ];

    extraModulePackages =
      let
        inherit (config.boot.kernelPackages) callPackage;
      in
      [ (callPackage "${inputs.self}/pkgs/kernel-module/tcp-brutal/package.nix" { }) ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  # fileSystems."/persist".neededForBoot = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
