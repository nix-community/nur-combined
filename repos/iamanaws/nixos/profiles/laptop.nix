{
  pkgs,
  nixosModules,
  ...
}:

{
  imports = with nixosModules; [
    profiles.core
    display.default
  ];

  # Pick only one of the below networking options.
  #networking.wireless = {
  #  enable = lib.mkForce true;
  #  networks = {
  #    "Replace SSID".psk = "Replace psk";
  #  };
  #}; # Enables wireless support via wpa_supplicant.
  #networking.networkmanager.enable = lib.mkForce false;

  # Power Management settings
  powerManagement = {
    enable = true;
    # TLP owns the tunables; PowerTOP remains installed for diagnostics.
    powertop.enable = false;
  };

  services = {
    upower.enable = true;

    thermald.enable = true;

    # Fingerprint Reader
    fprintd.enable = true;

    # https://linrunner.de/tlp/
    tlp = {
      enable = true;
      settings = {
        # AC/BAT/SAV settings map to TLP's performance/balanced/power-saver profiles.
        # Restore the power-source profile when plugging or unplugging the charger.
        TLP_AUTO_SWITCH = 1;
        TLP_PROFILE_AC = "PRF";
        TLP_PROFILE_BAT = "BAL";

        # If hot on AC, set TLP_AUTO_SWITCH above to 0 and enable:
        # TLP_PROFILE_DEFAULT = "BAL";

        # Intel HWP scales dynamically with powersave, including turbo when allowed.
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_SAV = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 60;
        CPU_MIN_PERF_ON_SAV = 0;
        CPU_MAX_PERF_ON_SAV = 50;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
        # Select with sudo tlp power-saver; return with sudo tlp balanced.
        CPU_BOOST_ON_SAV = 0;

        # TLP uses firmware profiles where the hardware supports them.
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        PLATFORM_PROFILE_ON_SAV = "low-power";

        # Delay recharging until below 40%, then charge to 80%.
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };

  # Hardware Acceleration
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  # https://nixos.wiki/wiki/Intel_Graphics
  # https://github.com/intel/libvpl?tab=readme-ov-file#dispatcher-behavior-when-targeting-intel-gpus
  #
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl

      # Open GL, Vulkan, and VAAPI drivers
      # intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)

      # Drivers for Quick Sync Video
      # vpl-gpu-rt        # for newer GPUs on NixOS >24.05 or unstable
      # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
      # intel-media-sdk   # for older GPUs
    ];
  };

  hardware.bluetooth.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];

}
