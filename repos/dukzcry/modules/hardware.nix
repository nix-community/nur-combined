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
    (mkIf (config.networking.hostName == "li-si-tsin") {
      boot.kernelParams = [ "mitigations=off" ];
      boot.extraModprobeConfig = ''
        options snd-hda-intel model=dell-headset-multi
      '';
      services.tlp = {
        enable = true;
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
