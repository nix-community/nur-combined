imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.hardware;
  any' = l: any (x: x == config.networking.hostName) l;
  laptop = any' [ "li-si-tsin" "si-ni-tsin" ];
  server = any' [ "robocat" ];
in {
  inherit imports;

  options.services.hardware = {
    enable = mkEnableOption ''
      Hardware tweaks for different hosts
    '';
    user = mkOption {
      type = types.str;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.fstrim.enable = true;
      boot.kernel.sysctl."vm.swappiness" = 1;
      boot.loader.systemd-boot.enable = true;
    })
    (mkIf (cfg.enable && server) {
      systemd.watchdog.runtimeTime = "30s";
      systemd.watchdog.rebootTime = "10m";
      systemd.watchdog.kexecTime = "10m";
      powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
    })
    (mkIf (cfg.enable && laptop) {
      hardware.bluetooth.enable = true;
      services.upower = {
        enable = true;
        percentageLow = 7;
        percentageCritical = 6;
        percentageAction = 5;
      };
      boot.blacklistedKernelModules = [ "uvcvideo" ];
      services.tlp = {
        enable = true;
      };
      programs.light.enable = true;
      users.users.${cfg.user}.extraGroups = [ "video" ];
    })
    (mkIf (cfg.enable && config.networking.hostName == "li-si-tsin") {
      services.upower = {
        # hybrid sleep hangs
        criticalPowerAction = "Hibernate";
      };
      boot.kernelParams = [ "mitigations=off" ];
      boot.extraModprobeConfig = ''
        options snd-hda-intel model=dell-headset-multi
      '';
      services.tlp = {
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "powersave";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          RUNTIME_PM_BLACKLIST = "00:14.0";
        };
      };
      hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
      services.nvidia.enable = true;
      hardware.monitor.config = {
        name = "eDP-1";
        setup = "00ffffffffffff004d104714000000002d190104a51d117806de50a3544c99260f5054000000010101010101010101010101010101011a3680a070381f403020350026a510000018000000100000000000000000000000000000000000100000000000000000000000000000000000fe004c513133334d314a5731350a2000cf";
        config = {
          enable = true;
          mode = "1920x1080";
          # scale doesn't work correctly
          transform = [
            [ 1.0 0.0 0.0 ]
            [ 0.0 1.0 0.0 ]
            [ 0.0 0.0 1.0 ]
          ];
          dpi = 96;
        };
        scale = 1.0;
      };
      hardware.monitor.monitorPort = "DP-1";
      services.picom = {
        enable = true;
        vSync = true;
        backend = "glx";
      };
    })
    (mkIf (cfg.enable && config.networking.hostName == "si-ni-tsin") {
      # wait for 6.1 kernel
      boot.extraModulePackages = with config.boot.kernelPackages; [ rtw8852be ];
      # keyboard
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernelPatches = [
        # mic
        {
          name = "acp6x-mach";
          patch = ./patch-acp6x-mach;
        }
        # bluetooth
        {
          name = "btusb";
          patch = ./patch-btusb;
        }
        # dp timeout
        {
          name = "dc_link_dp";
          patch = ./patch-dc_link_dp;
        }
      ];
      powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
      services.tlp = {
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
          CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        };
      };
      hardware.monitor.config = {
        name = "eDP";
        setup = "00ffffffffffff0009e5920a0000000013200104a51e137803ee96a3544c99260f4e510000000101010101010101010101010101010160d200a0a0403260302035002ebd10000018c89d00a0a0403260302035002ebd10000018000000fd003078c6c636010a202020202020000000fe004e4531343051444d2d4e5832200164701379000003011430690005ff099f002f001f003f0631000200040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004d90";
        config = {
          enable = true;
          mode = "2560x1600";
          # scale doesn't work correctly
          transform = [
            [ 1.0 0.0 0.0 ]
            [ 0.0 1.0 0.0 ]
            [ 0.0 0.0 1.0 ]
          ];
          dpi = 144;
        };
        scale = 1.0;
      };
      hardware.monitor.monitorPort = "DisplayPort-0";
      hardware.video.hidpi.enable = true;
      services.xserver.deviceSection = ''
        Option "TearFree" "true"
      '';
    })
  ];
}
