{ config, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    desktopManager = {
      xfce.enable = true;
      xterm.enable = false;
    };
    xautolock = {
      enable = true;
      time = 10;
      killtime = 24 * 60;
    };
  };
  environment.systemPackages = [
    pkgs.xfce.xfce4-xkb-plugin
  ];
}
