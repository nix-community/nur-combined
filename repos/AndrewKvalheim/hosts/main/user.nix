{ config, pkgs, ... }:

{
  imports = [
    ../../common/user.nix
    ./local/user.nix
  ];

  # Nix
  home.stateVersion = "22.05"; # Permanent

  # Host parameters
  host = {
    background = "file://${./resources/background.jpg}";
    cores = 16;
    display_density = 2;
    display_width = 3840;
    firefoxProfile = "ahrdm58c.default";
    local = ./local;
  };

  # Unfree packages
  allowedUnfree = [
    "attachments"
    "obsidian"
  ];

  # Display
  xdg.dataFile."icc/ThinkPad-T14.icc".source = ./resources/ThinkPad-T14.icc;

  # Applications
  home.packages = with pkgs; [
    album-art
    attachments
    audacity
    awscli2
    calibre
    chromium
    decompiler-mc
    digikam
    email-hash
    fastnbt-tools
    fontforge-gtk
    gpsprune
    graphviz
    hugin
    jitsi-meet-electron
    josm
    josm-hidpi
    kdenlive
    libreoffice
    losslesscut-bin
    mark-applier
    mcaselector
    python3Packages.meshtastic
    meshtastic-url
    minemap
    nbt-explorer
    obsidian
    picard
    prismlauncher
    qgis
    rapid-photo-downloader
    signal-desktop
    soundconverter
    thunderbird
    tor-browser-bundle-bin
    transmission_4-gtk
    video-trimmer
    watson
    whatsapp-for-linux
    whipper
    wireguard-vanity-address
    wireshark
    yt-dlp
  ];
  xdg.dataFile."JOSM/plugins/imagery_used.jar".source = "${pkgs.josm-imagery-used}/share/JOSM/plugins/imagery_used.jar";

  # File type associations
  xdg.mimeApps.defaultApplications = {
    "application/epub+zip" = "calibre-ebook-viewer.desktop";
    "application/x-ptoptimizer-script" = "hugin.desktop";
    "font/otf" = "org.gnome.font-viewer.desktop";
    "font/ttf" = "org.gnome.font-viewer.desktop";
    "x-scheme-handler/mailto" = "firefox.desktop";
  };

  # Environment
  home.sessionVariables = {
    ATTACHMENTS_ENV = config.home.homeDirectory + "/.attachments.env";
    EMAIL_HASH_DB = config.home.homeDirectory + "/akorg/resource/email-hash.db";
  };
}
