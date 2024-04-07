{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.services.xserver.desktopManager.xfce.enable {
  services.xserver = {
    enable = lib.mkDefault true;
  };
  environment.systemPackages = [ pkgs.xfce.xfce4-xkb-plugin ];
}
