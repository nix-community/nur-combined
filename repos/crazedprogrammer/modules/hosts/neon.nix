{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
  ];

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      # Skip the boot selection menu. In order to open it again, repeatedly press the space key on boot.
      timeout = 0;
    };

    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = import ../home/kernel (pkgs // {
      structuredExtraConfig = {
        MIVYBRIDGE = "y";
      };
    });
  };

  networking.hostName = "neon"; # Define your hostname.

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/67086bbd-73a7-4057-bfc6-72564be97cc1";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8688-2325";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0b60513b-c006-4e35-85f8-c69a2049f2ba"; }
    ];

  nix.maxJobs = 8;
  nix.buildCores = 8;

  # Intel wifi firmware
  hardware.enableRedistributableFirmware = true;

  services.logind.lidSwitch = "ignore";

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];

  services.xserver = {
    synaptics = {
      enable = true;
      minSpeed = "1";
      accelFactor = "0.002";
      maxSpeed = "2";
      twoFingerScroll = true;
      scrollDelta = -75;
      palmDetect = true;
      additionalOptions = ''
        Option "PalmMinWidth" "4"
        Option "PalmMinZ" "50"
      '';
    };
    config = ''
      Section "Device"
        Identifier "Intel Graphics"
        Driver "intel"
        Option "TearFree" "true"
      EndSection
    '';
  };
}
