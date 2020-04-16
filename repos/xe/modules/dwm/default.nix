{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.cadey.dwm;
  termDesktop = pkgs.writeTextFile {
    name = "website.within.st.desktop";
    destination = "/share/applications/website.within.st.desktop";
    text = ''
      [Desktop Entry]
      Exec=${pkgs.nur.repos.xe.st}/bin/st
      Icon=utilities-terminal
      Name[en_US]=Cadey st
      Name=Cadey st
      StartupNotify=true
      Terminal=false
      Type=Application
    '';
  };
in {
  imports = [ <home-manager/nixos> ];

  options = { cadey.dwm.enable = mkEnableOption "dwm"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.nur.repos.xe; [ dwm st termDesktop ];
    programs.slock.enable = true;
    services.xserver.windowManager.session = singleton {
      name = "dwm";
      start = with pkgs.nur.repos.xe; ''
        ${dwm}/bin/dwm &
        waitPID=$!
      '';
    };

    home-manager.users.cadey = let wp = ./cadey_seaside_wp.png;
    in {
      home.packages = with pkgs; [ dmenu libnotify ];

      home.file = {
        ".dwm/autostart.sh" = {
          executable = true;
          text = ''
            #!/bin/sh

            ${pkgs.feh}/bin/feh --bg-scale ${wp}
            ${pkgs.picom}/bin/picom --vsync --use-damage &
            ${pkgs.pasystray}/bin/pasystray &
            ${pkgs.dunst}/bin/dunst &
            ${pkgs.xorg.xmodmap}/bin/xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
            ${pkgs.nur.repos.xe.cabytcini}/bin/cabytcini &
          '';
        };

        ".config/dunst/dunstrc".source = ./dunstrc;
      };
    };
  };
}
