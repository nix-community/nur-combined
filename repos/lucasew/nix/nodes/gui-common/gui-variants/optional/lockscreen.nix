{
  config,
  pkgs,
  lib,
  ...
}:
let
  i3 = config.services.xserver.windowManager.i3.enable;
  sway = config.programs.sway.enable;
  hyprland = config.programs.hyprland.enable;
in
{
  config = lib.mkIf (i3 || sway || hyprland) {
    environment.systemPackages = [ pkgs.xss-lock ] ++ lib.optionals (sway || hyprland) [ pkgs.swaylock ];
  };
}
