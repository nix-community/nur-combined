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
    services.autorandr.enable = true;
    services.picom.enable = true;
  };
}
