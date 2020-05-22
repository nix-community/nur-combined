{ config, pkgs, ... }:

{
  imports = [ ./thinkpad.nix ];
  boot = {
    kernelParams = [ "i915.enable_psr=1" ];
    extraModprobeConfig = ''
      options iwlwifi 11n_disable=1
    '';
  };
  security = {
    pam.services = {
      slimlock.fprintAuth = false;
      slim.fprintAuth = false;
      login.fprintAuth = false;
      xscreensaver.fprintAuth = false;
    };
  };
  services = {
    fprintd.enable = true;
    tlp = {
      extraConfig = ''
        # CPU optimizations
        CPU_SCALING_GOVERNOR_ON_AC=performance
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        CPU_MIN_PERF_ON_AC=0
        CPU_MAX_PERF_ON_AC=100
        CPU_MIN_PERF_ON_BAT=0
        CPU_MAX_PERF_ON_BAT=50
        CPU_BOOST_ON_AC=1
        CPU_BOOST_ON_BAT=0
        # DEVICES (wifi, ..)
        DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
        DEVICES_TO_ENABLE_ON_AC="bluetooth wifi wwan"
        DEVICES_TO_DISABLE_ON_BAT="bluetooth"
        # Network management
        DEVICES_TO_DISABLE_ON_LAN_CONNECT=""
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT=""
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT=""
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT=""
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT=""
        DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT=""
        DISK_IDLE_SECS_ON_AC=0
        DISK_IDLE_SECS_ON_BAT=2
        MAX_LOST_WORK_SECS_ON_AC=15
        MAX_LOST_WORK_SECS_ON_BAT=60
        DISK_DEVICES="ata-Corsair_Force_LX_SSD_15256501000102160059"
        SOUND_POWER_SAVE_ON_AC=0
        SOUND_POWER_SAVE_ON_BAT=1
        USB_AUTOSUSPEND=1
        USB_BLACKLIST_BTUSB=1
      '';
    };
  };
}
