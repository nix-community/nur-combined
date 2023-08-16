{ global, config, pkgs, lib, ... }:

{
  imports = [
    ./i3.nix
    ./flatpak.nix
    ./dunst.nix
    ./lockscreen.nix
    ./kdeconnect.nix
  ];

  config = lib.mkIf config.services.xserver.windowManager.i3.enable {
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
      doublecmd
    ];
  };
}
