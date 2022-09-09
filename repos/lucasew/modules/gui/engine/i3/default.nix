{ global, config, pkgs, lib, ... }:
let
  inherit (lib) mkForce;

  inherit (pkgs.custom) wallpaper colorpipe;
in {
  imports = [
    ./polybar.nix
    ./i3.nix
    ./dunst.nix
    ./lockscreen.nix
  ];
  services.xserver = {
    enable = true;
    displayManager.defaultSession = "none+i3";
    desktopManager = {
      xterm.enable = false;
    };
    windowManager.i3 = {
      enable = true;
      configFile = "/etc/i3config";
    };
  };
  systemd.user.services.nm-applet = {
    path = with pkgs; [ networkmanagerapplet ];
    script = "nm-applet";
  };
  systemd.user.services.blueberry-tray = {
    path = with pkgs; [ blueberry ];
    script = "blueberry-tray; while true; do sleep 3600; done";
  };

  services.picom = {
    enable = true;
    vSync = true;
  };
  environment.systemPackages = with pkgs; [
    xfce.xfce4-screenshooter
    xfce.ristretto
    xfce.thunar
  ];
  environment.etc.wallpaper.source = wallpaper;
}
