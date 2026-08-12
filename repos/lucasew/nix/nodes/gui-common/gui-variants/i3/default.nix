{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./i3.nix
    ../optional/flatpak.nix
    ../optional/kdeconnect-indicator.nix
    ../optional/dunst.nix
  ];

  config = lib.mkIf config.services.xserver.windowManager.i3.enable {

    security.polkit.agent.enable = true;

    # Redshift
    services.redshift.enable = true;

    services.tumbler.enable = true;

    services.dunst.enable = true;
    programs.kdeconnect.enable = true;

    services = {
      displayManager.defaultSession = lib.mkDefault "none+i3";
      xserver = {
        enable = lib.mkDefault true;
        windowManager.i3 = {
          configFile = "/etc/i3config";
        };
      };
    };

    services.picom = {
      enable = true;
      vSync = true;
    };
    environment.systemPackages = with pkgs; [
      eog # eye of gnome
      ristretto
      pcmanfm
      kitty
    ];
  };
}
