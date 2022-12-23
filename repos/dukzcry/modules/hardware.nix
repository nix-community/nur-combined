imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.hardware;
  any' = l: any (x: x == config.networking.hostName) l;
  laptop = any' [ "li-si-tsin" ];
  server = any' [ "robocat" ];
  desktop = any' [ "powerhorse" ];
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
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
        criticalPowerAction = "Hibernate";
      };
      boot.blacklistedKernelModules = [ "uvcvideo" ];
      services.tlp = {
        enable = true;
      };
      programs.light.enable = true;
      users.users.${cfg.user}.extraGroups = [ "video" ];
    })
    (mkIf (cfg.enable && config.networking.hostName == "li-si-tsin") {
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
        };
        dpi = 96;
        size = 16;
      };
      hardware.monitor.monitorPort = "DP-1";
      services.picom = {
        enable = true;
        vSync = true;
        backend = "glx";
      };
    })
    (mkIf (cfg.enable && desktop) {
      hardware.bluetooth.enable = true;
      # MT7921K is supported starting from 5.17
      boot.kernelPackages = pkgs.linuxPackages_6_0;
      powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
      services.xserver.dpi = 144;
      services.logind.extraConfig = ''
        HandlePowerKey=suspend
      '';
    })
  ];
}
