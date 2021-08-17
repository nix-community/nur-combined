unstable: ddccontrol: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.monitor;
in {
  imports = [ ddccontrol ];

  options.hardware.monitor = {
    enable = mkEnableOption ''
      Adoptions for monitor
    '';
  };

  config = mkIf cfg.enable {
    services.autorandr.enable = true;
    programs.light.enable = true;
    services.ddccontrol.enable = true;
    hardware.i2c.enable = true;
  };
}
