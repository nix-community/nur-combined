{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.sessions.gdm;
in {
  options.sessions.gdm = {
    enable = mkEnableOption "Enable GDM3";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
  };
}
