{ config, lib, pkgs, ... }:

{
  imports = [
  ];
  config = lib.mkIf config.programs.hyprland.enable {
    services.dunst.enable = true;
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
      path = with pkgs; [
          (blueberry.overrideAttrs (old: {
            patches = (old.patches or []) ++ [ ./blueberry-tray-fix.patch ];
            buildInputs = old.buildInputs ++ [ pkgs.libappindicator-gtk3 ];
          }))
      ];
      script = "blueberry-tray; while true; do sleep 3600; done";
    };

    systemd.user.services.polkit-agent = {
      script = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
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
