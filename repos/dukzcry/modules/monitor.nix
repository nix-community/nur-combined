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
    programs.light.enable = true;
    environment.systemPackages = with pkgs; [ ddcutil ];
    hardware.i2c.enable = true;
  };
}
