{
  config,
  inputs,
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
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      systemd-boot.enable = true;
      timeout = 3;
    };

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
    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;

      kernelModules = [
        "hv_vmbus" # for hyper-V
        "hv_netvsc"
        "hv_utils"
        "hv_storvsc"
      ];
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems = {
    "/efi" = {
      device = "/dev/sda2";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/" = {
      device = "/dev/sda3";
      fsType = "btrfs";
      options = [
        "subvol=/root"
        "compress-force=zstd:1"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };
  }
  //
    lib.genAttrs
      [
        "/home"
        "/nix"
        "/var"
      ]
      (name: {
        device = "/dev/sda3";
        fsType = "btrfs";
        options = [
          "subvol=${name}"
          "compress-force=zstd:1"
          "noatime"
          "discard=async"
          "space_cache=v2"
          "nosuid"
          "nodev"
        ];
      });
}
