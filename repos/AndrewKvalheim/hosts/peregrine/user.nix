{ config, pkgs, ... }:

let
  inherit (config.home) homeDirectory;

  system = import <nixpkgs/nixos> { };
in
{
  imports = [
    ../../user.nix
    ./user.local.nix
  ];

  # Nix
  home.stateVersion = "24.11"; # Permanent

  # System configuration
  system = system.config;

  # Host parameters
  host = {
    dir = ./.;
    firefox.profile = "gpihihlj.default";
  };

  # Modules
  programs.yt-dlp.enable = true;

  # Packages
  home.packages = with pkgs; [
    awscli2
    chromium
    email-hash
    josm
    libreoffice
    mark-applier
    prusa-slicer
    tor-browser
    transmission_4-gtk
  ];
  xdg.dataFile."JOSM/plugins/imagery_used.jar".source = "${pkgs.josm-imagery-used}/share/JOSM/plugins/imagery_used.jar";

  # File type associations
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "firefox.desktop";
  };

  # Password store
  programs.gopass.settings.mounts.path = "${homeDirectory}/akorg/resource/password-store";

  # Notes
  programs.joplin-desktop.extraConfig = let filesystem = 2 /* enum */; in {
    "sync.target" = filesystem;
    "sync.${toString filesystem}.path" = "${homeDirectory}/akorg/resource/joplin-sync";
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
    EMAIL_HASH_DB = "${homeDirectory}/akorg/resource/email-hash/email-hash.db";
  };
}
