{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
    ../overrides/thinkfan.nix
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
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    kernelPatches = [ {
      name = "config-neon";
      patch = null;
      extraConfig = ''
        MIVYBRIDGE y
        DRM_AMDGPU n
      '';
    } ];
  };

  networking.hostName = "neon"; # Define your hostname.

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/566cacb4-81ea-48bb-929f-a60951b852cf";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6989-46C8";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/bf1dc388-c115-40c2-bef6-644f717e19a7"; }
      { device = "/dev/disk/by-uuid/0ddc6bd7-c98e-4ea9-b2b2-535c91f61595"; }
    ];

  nix.maxJobs = 8;
  nix.buildCores = 8;

  # Intel wifi firmware
  hardware.enableRedistributableFirmware = true;

  services.logind.lidSwitch = "ignore";

  environment.systemPackages = with pkgs; [
    light tpacpi-bat config.boot.kernelPackages.cpupower
  ];

  # Using TLP because Powertop doesn't work. The cause of this is that the
  # kernel module cpufreq_stats does not exist for some reason, even with CONFIG_CPU_FREQ_STATS=y.
  services.tlp = {
    enable = true;
    extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=performance
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      START_CHARGE_THRESH_BAT0=70
      STOP_CHARGE_THRESH_BAT0=78
    '';
  };
  systemd.services = {
    tlp = {
      wantedBy = lib.mkForce [ ];
    };
    # This option makes Firefox stop working for some strange reason, unfortunately.
    # I'll have to find another way to improve boot time.
    # systemd-udev-settle.serviceConfig.ExecStart = ["" "${pkgs.coreutils}/bin/true"];

    battery-watchdog = {
      description = "Battery watchdog";
      path = with pkgs; [ systemd ];
      script = ''
        ${../../dotfiles/bin/battery-watchdog}
      '';
      startAt = "*-*-* *:*:00";
    };
  };
  services.thinkfan-override = {
    enable = true;
    sensors = ''
      hwmon /sys/class/thermal/thermal_zone1/temp
      hwmon /sys/class/thermal/thermal_zone0/temp
    '';
    levels = ''
      (0,     0,      58)
      (1,     42,     62)
      (2,     57,     68)
      (3,     63,     73)
      (6,     68,     75)
      (7,     70,     84)
      (127,   80,     32767)
    '';
    extraArgs = [ "-s 1" "-b 0" ];
  };

  services.xserver = {
    videoDrivers = [ "nouveau" "intel" "modesetting" "vesa" ];
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
  };
}
