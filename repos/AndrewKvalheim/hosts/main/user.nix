{ config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
  inherit (lib) escapeShellArg getExe getExe';
  inherit (pkgs) substitute writeShellScript;

  system = import <nixpkgs/nixos> { };
in
{
  imports = [
    ../../user.nix
    ./user.local.nix
  ];

  # Nix
  home.stateVersion = "22.05"; # Permanent

  # System configuration
  system = system.config;

  # Host parameters
  host = {
    dir = ./.;
    firefox.profile = "ahrdm58c.default";
  };

  # Unfree packages
  allowedUnfree = [
    "attachments"
  ];

  # Display
  xdg.dataFile."icc/ThinkPad-P16s-OLED.icc".source = ./assets/ThinkPad-P16s-OLED.icc;

  # Modules
  programs.watson.enable = true;
  programs.yt-dlp.enable = true;

  # Packages
  home.packages = with pkgs; [
    album-art
    attachments
    awscli2
    calibre
    chromium
    decompiler-mc
    digikam
    dino
    email-hash
    fastnbt-tools
    filter-imf
    fontforge-gtk
    freecad
    gpsprune
    graphviz
    hugin
    jitsi-meet-electron
    josm
    kdePackages.kdenlive
    libreoffice
    losslesscut-bin
    mark-applier
    mcaselector
    nvtopPackages.amd
    meshtastic-url
    minemap
    nbt-explorer
    picard
    (prismlauncher.override { jdks = [ jdk25 ]; })
    prusa-slicer
    qgis
    rapid-photo-downloader
    signal-desktop
    soundconverter
    tenacity
    thunderbird
    tor-browser
    transmission_4-gtk
    video-trimmer
    wasistlos
    whipper
    wireguard-vanity-address
    wireshark
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

  # Password store
  programs.gopass.settings.mounts.path = "${homeDirectory}/akorg/resource/password-store";

  # Notes
  programs.joplin-desktop.extraConfig = let filesystem = 2 /* enum */; in {
    "sync.target" = filesystem;
    "sync.${toString filesystem}.path" = "${homeDirectory}/akorg/resource/joplin-sync";
  };

  # GNOME Shell launcher scripts
  launcherScripts = with pkgs; {
    "IMF → filtered IMF" = "kitty ${escapeShellArg (writeShellScript "filter-imf" ''
        ${getExe' wl-clipboard "wl-paste"} --no-newline --type 'text' \
        | CLICOLOR_FORCE='✓' ${getExe filter-imf} \
        | ${getExe' wl-clipboard "wl-copy"} --type 'TEXT'
      '')}";
  };

  # Workaround for dino/dino#299
  xdg.configFile."autostart/im.dino.Dino.desktop".source = substitute {
    src = "${pkgs.dino}/share/applications/im.dino.Dino.desktop";
    substitutions = [ "--replace-fail" "Exec=dino %U" "Exec=dino --gapplication-service" ];
  };

  # Unison
  services.unison.pairs = {
    "3d-printing" = {
      when = "run-media-ak-ANDREW.mount"; # TODO: Provide escapeSystemdPath in Home Manager
      roots = [ "${homeDirectory}/akorg/project/current/3d-printing" "/run/media/ak/ANDREW/3d-printing" ];
      commandOptions.fat = "true";
    };
  };

  # Environment
  home.sessionVariables = {
    ATTACHMENTS_ENV = "${homeDirectory}/.attachments.env";
    EMAIL_HASH_DB = "${homeDirectory}/akorg/resource/email-hash/email-hash.db";
  };
}
