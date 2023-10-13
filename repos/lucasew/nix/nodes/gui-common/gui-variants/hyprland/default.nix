{ config, lib, pkgs, ... }:

{
  imports = [
    ../optional/flatpak-wayland.nix
    ../optional/kdeconnect-indicator.nix
    ../optional/dunst.nix
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

    systemd.user.services.swayidle = {
      path = with pkgs; [
        swayidle
        config.programs.hyprland.package
        playerctl
      ];
      script = ''
        swayidle -w \
          timeout 600 'swaylock -f'
          timeout 605 'hyprctl dispatch dpms off' \
          resume 'hyprctl dispatch dpms on'
          before-sleep 'playerctl pause'
      '';
    };

    security.pam.services.swaylock = {};

    systemd.user.services.dotfile-waybar = {
      path = with pkgs; [
        script-directory-wrapper
        custom.colorpipe
      ];
      script = ''
        mkdir ~/.config/waybar -p
        cat $(sdw d root)/nix/nodes/gui-common/gui-variants/hyprland/waybar/style.css | colorpipe > ~/.config/waybar/style.css
        cat $(sdw d root)/nix/nodes/gui-common/gui-variants/hyprland/waybar/config | colorpipe > ~/.config/waybar/config
      '';
      restartTriggers = [ "${./waybar/style.css}" "${./waybar/config}" ];
      wantedBy = [ "default.target" ];
    };

    systemd.user.services.dotfile-hyprland = {
      path = with pkgs; [
        script-directory-wrapper
        custom.colorpipe
      ];
      script = ''
        mkdir ~/.config/hypr -p
        cat $(sdw d root)/nix/nodes/gui-common/gui-variants/hyprland/hypr/hyprland.conf | colorpipe > ~/.config/hypr/hyprland.conf
      '';
      restartTriggers = [ "${./hypr/hyprland.conf}" ];
      wantedBy = [ "default.target" ];
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
