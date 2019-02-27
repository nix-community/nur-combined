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
    kernelParams = [ "i915.enable_psr=1" "i915.enable_fbc=1" "i915.fastboot=1" ];
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

  # Using TLP because Powertop doesn't work. The cause of this is that the
  # kernel module cpufreq_stats does not exist for some reason, even with CONFIG_CPU_FREQ_STATS=y.
  services.tlp = {
    enable = true;
    extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=performance
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
    '';
  };
  systemd.services = {
    tlp = {
      wantedBy = lib.mkForce [ ];
    };
    systemd-udev-settle.serviceConfig.ExecStart = ["" "${pkgs.coreutils}/bin/true"];

    battery-watchdog = {
      description = "Battery watchdog";
      path = with pkgs; [ systemd ];
      script = ''
        ${../../dotfiles/bin/battery-watchdog.sh}
      '';
      startAt = "*-*-* *:*:00";
    };
  };

  services.xserver = {
    videoDrivers = [ "intel" "modesetting" "vesa" ];
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
  };
}
