{
  config,
  pkgs,
  lib,
  ...
}:
let
  enable =
    config.services.xserver.windowManager.i3.enable
    || config.programs.sway.enable
    || config.programs.hyprland.enable;
in
{
  config = lib.mkIf enable {
    systemd.user.services.nm-applet = {
      path = [ pkgs.networkmanagerapplet ];
      script = "nm-applet";
      restartIfChanged = true;
    };
    systemd.user.services.blueberry-tray = {
      path = [ pkgs.blueman ];
      script = "blueman-applet; while true; do sleep 3600; done";
      restartIfChanged = true;
    };
  };
}
