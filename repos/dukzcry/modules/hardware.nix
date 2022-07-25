imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.hardware;
in {
  inherit imports;

  options.services.hardware = {
    enable = mkEnableOption ''
      Hardware tweaks for different hosts
    '';
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.upower.enable = true;
      # hybrid sleep hangs
      services.upower.criticalPowerAction = "Hibernate";
      services.upower.percentageLow = 7;
      services.upower.percentageCritical = 6;
      services.upower.percentageAction = 5;

      services.tlp.enable = true;
    })
    (mkIf (cfg.enable && config.networking.hostName == "li-si-tsin") {
      boot.blacklistedKernelModules = [ "uvcvideo" ];
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
    })
  ];
}
