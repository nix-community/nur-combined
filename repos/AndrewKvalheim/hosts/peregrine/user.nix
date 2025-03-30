{ config, pkgs, ... }:

{
  imports = [
    ../../common/user.nix
    ./local/user.nix
  ];

  # Nix
  home.stateVersion = "24.11"; # Permanent

  # Host parameters
  host = {
    background = "file://${./resources/background.jpg}";
    cores = 4;
    display_density = 1.0;
    display_width = 1280;
    firefox.profile = "gpihihlj.default";
    local = ./local;
  };

  # Applications
  home.packages = with pkgs; [
    awscli2
    chromium
    josm
    libreoffice
    mark-applier
    tor-browser-bundle-bin
    transmission_4-gtk
    yt-dlp
  ];
  xdg.dataFile."JOSM/plugins/imagery_used.jar".source = "${pkgs.josm-imagery-used}/share/JOSM/plugins/imagery_used.jar";

  # File type associations
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "firefox.desktop";
  };
}
