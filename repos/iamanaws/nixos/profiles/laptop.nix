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
    powertop.enable = true;
  };

  services.upower = {
    enable = true;
  };

  services.thermald.enable = true;

  # https://linrunner.de/tlp/
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;

      # Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

      # Enable if Laptop runs hot when on power, but not on battery
      # Enable always run on battery mode
      # TLP_DEFAULT_MODE = "BAT";
      # TLP_PERSISTENT_DEFAULT = 1;
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

  # Fingerprint Reader
  services.fprintd.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];

}
