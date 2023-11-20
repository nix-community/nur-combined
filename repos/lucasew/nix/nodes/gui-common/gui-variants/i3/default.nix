{ global, config, pkgs, lib, ... }:

{
  imports = [
    ./i3.nix
    ./lockscreen.nix
    ../optional/flatpak-wayland.nix
    ../optional/kdeconnect-indicator.nix
    ../optional/dunst.nix
  ];

  config = lib.mkIf config.services.xserver.windowManager.i3.enable {
    # Redshift
    services.redshift.enable = true;

    services.tumbler.enable = true;

    services.dunst.enable = true;
    programs.xss-lock.enable = true;
    programs.kdeconnect.enable = true;

    services.xserver = {
      enable = lib.mkDefault true;
      displayManager.defaultSession = lib.mkDefault "none+i3";
      windowManager.i3 = {
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
      gnome.eog # eye of gnome
      xfce.ristretto
      mate.caja
      doublecmd
    ];
  };
}
