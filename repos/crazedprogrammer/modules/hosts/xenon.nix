{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xenon"; # Define your hostname.

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = import ../home/kernel (pkgs // {
    structuredExtraConfig = {
      MZEN = "y";

      # Don't need Btrfs on this system, saves ~200ms at boot time due to
      # unnecessary raid6 benchmarks.
      BTRFS_FS = "n";
      BTRFS_FS_POSIX_ACL = null;
    };
  });

 fileSystems."/" =
    { device = "/dev/disk/by-uuid/8ee00b41-b4a1-4290-a01e-8b8788841c76";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A024-0A4C";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4133fbc7-683f-4267-a6fb-126c7e80e29b"; }
    ];

  nix.maxJobs = 12;
  nix.buildCores = 12;

  environment.systemPackages = with pkgs; [
    hdparm #docker_compose
  ];

 #virtualisation.docker = {
 #  enable = true;
 #};

  # AMD polaris firmware
  hardware.enableRedistributableFirmware = true;

  services.xserver.config = ''
    Section "Monitor"
      Identifier "DP-1"
      VertRefresh 144.0 - 144.0
    EndSection
    Section "Monitor"
      Identifier "DVI-D-1"
      Option "LeftOf" "DP-1"
    EndSection
    Section "Device"
      Identifier "AMD"
      Driver "amdgpu"
      Option "TearFree" "true"
    EndSection
    Section "InputClass"
      Identifier "Logitech G403 Prodigy Gaming Mouse"
      MatchIsPointer "yes"
      Option "AccelerationProfile" "-1"
      Option "AccelerationScheme" "none"
      Option "AccelSpeed" "-1"
      Option "Resolution" "3500"
    EndSection
  '';
}
