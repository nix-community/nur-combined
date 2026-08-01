{
  outputs,
  lib,
  pkgs,
  darwinModules,
  config,
  ...
}:

let
  userHome = config.users.users.${config.system.primaryUser}.home;
in
{
  imports = [
    darwinModules.default
    ./homebrew.nix
  ];

  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
  ];

  system.primaryUser = "iamanaws";

  fonts.packages = with pkgs.nerd-fonts; [ caskaydia-mono ];

  programs.mas.packages = {
    "Bitwarden" = 1352778147;
    "Command X" = 6448461551;
    "CopyClip" = 595191960;
    "Plain Text Editor" = 1572202501;
    "Pixea" = 1507782672;
    "Xcode" = 497799835;
    "Grab2Text" = 6475956137;
  };

  environment.systemPackages = with pkgs; [
    asciidoctor
    cachix
    code-cursor
    colima
    docker
    docker-compose
    # flameshot
    # google-chrome
    jetbrains-toolbox
    jujutsu
    libreoffice-bin
    mongodb-compass
    mongodb-atlas-cli
    mongodb-cli
    ngrok
    postman
    # spotify
    nodejs
    nur.iamanaws.bitbucket-cli
    nur.iamanaws.clickup-cli
  ];

  system.defaults = {
    controlcenter.WiFi = lib.mkForce "show";

    dock = {
      autohide = true;
      expose-group-apps = true;
      magnification = false;
      minimize-to-application = true;
      mru-spaces = false;
      persistent-apps = [
        "/System/Applications/Notes.app"
        "/System/Applications/System Settings.app"
        "/Applications/Google Chrome.app"
        "/Applications/Nix Apps/Cursor.app"
        "/Applications/Nix Apps/Ghostty.app"
        "/Applications/Nix Apps/MongoDB Compass.app"
        # "/Applications//Nix Apps/Postman.app"
        # "/Applications/Nix Apps/Spotify.app"
        # "/Applications/ClickUp.app"
        "${userHome}/Applications/Home Manager Apps/T3 Code (Alpha).app"
      ];
      show-recents = false;

      wvous-bl-corner = 14;
      wvous-br-corner = 4;
      wvous-tl-corner = 5;
      wvous-tr-corner = 2;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      NewWindowTarget = "Other";
      NewWindowTargetPath = "file://${userHome}/Downloads/";
      ShowPathbar = true;
      _FXShowPosixPathInTitle = false;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
    };
  };
}
