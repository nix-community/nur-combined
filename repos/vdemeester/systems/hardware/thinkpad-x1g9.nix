{ config, pkgs, ... }:
{
  # NixOS options
  boot = {
    blacklistedKernelModules = [
      "sierra_net" # sierra wireless modules
      "cdc_mbim" # modem mobile broadband modules
      "cdc_ncm" # similar
    ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
    '';
    initrd = {
      availableKernelModules = [
        "nvme" # required for nvme disks
        "thunderbolt" # required for thunderbolt (dock, ...)
        "dm-mod"
        "cryptd" # required for encryption
        "ahci" # sata controller, might not be needed
        "xhci_pci" # usb controller related
        "usb_storage" # usb storage related
        "sd_mod" # block device related
        "sdhci_pci" # block device related as well
        "aesni-intel" # advanced encryption for intel
      ];
    };
    loader.efi.canTouchEfiVariables = true;
  };
  hardware = {
    enableAllFirmware = true;
    trackpoint.enable = false;
    cpu.intel.updateMicrocode = true;
    opengl.extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl intel-media-driver ];
  };
  services = {
    hardware.bolt.enable = true;
    # throttled.enable = true; # might not be needed
    tlp = {
      # FIXME: to disable
      enable = false;
      settings = {
        # Charge threshold
        # If the battery is used somewhat frequently,
        # set the start threshold at around 85% and stop at 90%. This
        # will still give a good lifespan benefit over keeping the
        # battery charged to 100%.
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
        # CPU optimizations
        "CPU_SCALING_GOVERNOR_ON_AC" = "performance";
        "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
        "PLATFORM_PROFILE_ON_AC" = "balanced"; # or performance ?
        "PLATFORM_PROFILE_ON_BAT" = "low-power";
        "CPU_MIN_PERF_ON_AC" = 0;
        "CPU_MAX_PERF_ON_AC" = 100;
        "CPU_MIN_PERF_ON_BAT" = 0;
        "CPU_MAX_PERF_ON_BAT" = 75;
        # DEVICES (wifi, ..)
        "DEVICES_TO_DISABLE_ON_STARTUP" = "";
        "DEVICES_TO_ENABLE_ON_AC" = "bluetooth wifi wwan";
        "DEVICES_TO_DISABLE_ON_BAT" = "";
        # Network management
        "DEVICES_TO_DISABLE_ON_LAN_CONNECT" = "wifi";
        "DEVICES_TO_DISABLE_ON_WIFI_CONNECT" = "";
        "DEVICES_TO_DISABLE_ON_WWAN_CONNECT" = "";
        "DEVICES_TO_ENABLE_ON_LAN_DISCONNECT" = "wifi";
        "DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT" = "";
        "DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT" = "";
        # Docking
        "DEVICES_TO_DISABLE_ON_DOCK" = "wifi";
        "DEVICES_TO_ENABLE_ON_UNDOCK" = "wifi";
        # Make sure it uses the right hard drive
        "DISK_DEVICES" = "nvme0n1p1";
      };
    };
    udev.extraRules = ''
      # Rules for Lenovo Thinkpad WS Dock
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    '';
  };
}
