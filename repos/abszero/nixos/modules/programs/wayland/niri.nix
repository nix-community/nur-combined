{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.niri;
in

{
  options.abszero.programs.niri.enable = mkEnableOption "scrolling wayland compositor";

  # Most of the config is in home-manager
  config.programs.niri = mkIf cfg.enable {
    enable = true;
    package = pkgs.niri-unstable;
  };
}
