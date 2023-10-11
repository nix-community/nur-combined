{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.hyprland.enable {
    programs.regreet.enable = true;
    programs.waybar.enable = true;
    programs.kdeconnect.enable = true;
    programs.xss-lock.lockerCommand = "swaylock -f";
    programs.xss-lock.enable = true;

    systemd.user.services.nm-applet = {
      path = with pkgs; [ networkmanagerapplet ];
      script = "nm-applet";
    };
    systemd.user.services.blueberry-tray = {
      path = with pkgs; [ blueberry ];
      script = "blueberry-tray; while true; do sleep 3600; done";
    };

    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];

    environment.systemPackages = with pkgs; [
      custom.rofi
      swaylock
      gnome.eog # eye of gnome
      xfce.ristretto
      xfce.thunar
      playerctl
      brightnessctl
      gscreenshot
    ];
  };
}
