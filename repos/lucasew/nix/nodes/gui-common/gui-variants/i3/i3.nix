{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (pkgs) makeDesktopItem;
  lockerSpace = makeDesktopItem {
    name = "locker";
    desktopName = "Bloquear Tela";
    icon = "lock";
    type = "Application";
    exec = "sdw utils i3wm lock-screen";
  };
in
{

  config = lib.mkIf config.services.xserver.windowManager.i3.enable {
    # Portal configuration
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.config.common.default = "*";
    xdg.portal.xdgOpenUsePortal = true;

    # System packages
    environment.systemPackages = [
      lockerSpace
      pkgs.rofi
    ];

    # Display manager
    services.xserver.displayManager.lightdm.enable = true;

    # i3 window manager
    services.xserver.windowManager.i3.extraPackages = with pkgs; [
        playerctl
        rofi
        pulseaudio
        feh
        brightnessctl
        maim
        xclip
        i3status
        unstable.i3pystatus
        mate-polkit
      ];
  };
}
