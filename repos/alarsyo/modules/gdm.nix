{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.displayManager.gdm;
in {
  options.my.displayManager.gdm.enable = mkEnableOption "GDM setup";

  config = mkIf cfg.enable {
    services.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
