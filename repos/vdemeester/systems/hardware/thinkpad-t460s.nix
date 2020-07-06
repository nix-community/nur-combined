{ config, pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  imports = [
    (sources.nixos-hardware + "/lenovo/thinkpad/t460s")
    (sources.nixos-hardware + "/common/pc/ssd")
    ./thinkpad.nix
  ];
  nix.maxJobs = 12;
  services = {
    tlp = {
      extraConfig = ''
        # CPU optimizations
        CPU_SCALING_GOVERNOR_ON_AC=performance
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        CPU_MIN_PERF_ON_AC=0
        CPU_MAX_PERF_ON_AC=100
        CPU_MIN_PERF_ON_BAT=0
        CPU_MAX_PERF_ON_BAT=50
        # DEVICES (wifi, ..)
        DEVICES_TO_DISABLE_ON_STARTUP=""
        DEVICES_TO_ENABLE_ON_AC="bluetooth wifi wwan"
        DEVICES_TO_DISABLE_ON_BAT=""
        # Network management
        DEVICES_TO_DISABLE_ON_LAN_CONNECT=""
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT=""
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT=""
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT=""
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT=""
        DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT=""
        # Docking
        DEVICES_TO_DISABLE_ON_DOCK="wifi"
        DEVICES_TO_ENABLE_ON_UNDOCK="wifi"
        # Make sure it uses the right hard drive
        DISK_DEVICES="nvme0n1p3"
      '';
    };
    xserver = {
      dpi = 128;
    };
  };
}
