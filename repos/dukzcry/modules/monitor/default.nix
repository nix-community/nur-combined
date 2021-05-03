unstable: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.monitor;
in {
  options.hardware.monitor = {
    enable = mkEnableOption ''
      Adoptions for monitor
    '';
  };

  config = mkIf cfg.enable {
    #services.autorandr.enable = true;
    services.xserver.dpi = 150;
    services.picom.enable = true;
    environment = {
      systemPackages = with pkgs; [ unstable.xorg.xrandr ];
    };
  };
}
