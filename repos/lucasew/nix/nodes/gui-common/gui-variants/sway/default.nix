{
  config,
  pkgs,
  lib,
  ...
}:

let
  lockerSpace = pkgs.makeDesktopItem {
    name = "locker";
    desktopName = "Bloquear Tela";
    icon = "lock";
    type = "Application";
    exec = "sdw utils i3wm lock-screen";
  };
in

{
  imports = [
    ../optional/flatpak.nix
    ../optional/kdeconnect-indicator.nix
    ../optional/dunst.nix
  ];
  config = lib.mkIf config.programs.sway.enable {
    programs.ssh.startAgent = true;

    security.soteria.enable = true;

    # Swayidle for power management
    systemd.user.services.swayidle = {
      partOf = [ "graphical-session.target" ];
      path = with pkgs; [ swayidle procps ];
      restartIfChanged = true;
      script = ''
        PATH=$PATH:/run/current-system/sw/bin
        exec swayidle -w -d \
          timeout 300 'workspaced driver power lock' \
          timeout 10 'pgrep swaylock && workspaced driver screen off' \
          resume 'workspaced driver screen on' \
          before-sleep 'workspaced driver power lock'
      '';
    };

    # XDG Portal for Wayland
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      config.common.default = "wlr";
      wlr.enable = true;
    };

    # Display Manager
    services.displayManager.sessionData.autologinSession = lib.mkDefault "sway";
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.enable = true;

    services.flatpak.enable = true;
    services.tumbler.enable = true;
    services.dunst.enable = true;
    services.gammastep.enable = true;
    programs.waybar.enable = true;
    programs.kdeconnect.enable = true;

    # System packages
    environment.systemPackages = with pkgs; [
      wlr-randr
      wl-clipboard
      grim
      imv
      eog # eye of gnome
      ristretto
      pcmanfm
      kitty
      slurp
      rofi
      swaybg
      lockerSpace
      playerctl
      pulseaudio
      feh
      brightnessctl
      unstable.i3pystatus
    ];

  };
}
