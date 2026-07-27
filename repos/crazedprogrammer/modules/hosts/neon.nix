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
  };

  networking.hostName = "neon"; # Define your hostname.

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/37796d43-4ff7-4037-b3b4-6b7df7c5b78b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B829-AF71";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9b01e592-1c2e-429d-8dbd-552c6b5788c1"; }
    ];

  nix.maxJobs = 8;
  nix.buildCores = 8;

  # Intel wifi firmware
  hardware.enableRedistributableFirmware = true;

  services.logind.lidSwitch = "ignore";

  environment.systemPackages = with pkgs; [
    light tpacpi-bat config.boot.kernelPackages.cpupower batsignal
  ];

  # Using TLP because Powertop doesn't work. The cause of this is that the
  # kernel module cpufreq_stats does not exist for some reason, even with CONFIG_CPU_FREQ_STATS=y.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
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
    # Note: displaylink can be added for external USB-C monitor support
    videoDrivers = [ "nouveau" "modesetting" "vesa" ];
    libinput = {
      enable = true;
      touchpad.naturalScrolling = false;
    };
    config = ''
      Section "Device"
        Identifier "nvidia card"
        Driver "nouveau"
        Option "GLXVBlank" "on"
      EndSection
    '';
  };

  # Enable printing to Canon Pixma MG5750.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];
  # Enable Avahi for printer discovery via mDNS.
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
}
