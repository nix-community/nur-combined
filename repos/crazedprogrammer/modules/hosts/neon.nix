{ config, lib, pkgs, ... }:

let
  powersave = false;
in

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
    kernelParams = (if powersave then [ "i915.enable_psr=1" "i915.enable_fbc=1" ] else [])
                     ++ [ "i915.fastboot=1" ];
    kernelPackages = import ../home/kernel (pkgs // {
      structuredExtraConfig = {
        MIVYBRIDGE = "y";
        # Enable cpufreq stats for powertop.
        CPU_FREQ_STAT = "y";
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

  powerManagement = {
    cpuFreqGovernor = if powersave then "powersave" else "performance";
    powertop.enable = powersave;
  };

  services.xserver = {
    videoDrivers = [ "intel" "modesetting" "vesa" ];
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
  };
}
