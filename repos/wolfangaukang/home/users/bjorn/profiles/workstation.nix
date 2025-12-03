{
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:

let
  localLib = import "${inputs.self}/lib" { inherit inputs lib; };
  inherit (localLib) obtainIPV4Address;

in
{
  imports = [
    ./chromium.nix
    ./firefox.nix
    ./kitty.nix
  ];

  home = {
    packages = with pkgs; [
      # libreoffice NOTE: Not building since version 25
      mpv
      mupdf
      multifirefox
      onlyoffice-desktopeditors
      telegram-desktop
      thunderbird
      vdhcoapp
    ];
    persistence."/mnt/persist/home/bjorn" =
      let
        generatePaths = prefix: pathsList: map (dir: "${prefix}/${dir}") pathsList;
      in
      {
        allowOther = osConfig.programs.fuse.userAllowOther;
        directories =
          let
            configDirs = generatePaths ".config/" [
              "BraveSoftware"
              "calibre"
              "dconf"
              "fish"
              "Joplin"
              "joplin-desktop"
              "keepassxc"
              "pulse"
              "pulumi"
              "sops"
              "syncthing"
              # Work
              # TODO: Limit this to specialisation
              "keybase"
              "Keybase"
              "remmina"
              "Slack"
              # Cinnamon
              "cinnamon"
              "menus"
              "nemo"
            ];
          in
          configDirs
          ++ [
            ".aws" # TODO: Limit this one to specialisation
            ".cache/nix-index"
            ".gnupg"
            ".local"
            ".mozilla"
            ".ssh"
            ".thunderbird"
            "Aparatoj"
            "Biblioteko"
            "Bildujo"
            "Dokumentujo"
            "Elsxutujo"
            "Projektujo"
            "Screenshots"
            "Utilecoj"
          ];
        files =
          let
            configFiles = generatePaths ".config" [
              "mimeapps.list"
              "QtProject.conf"
            ];
          in
          configFiles
          ++ [
            ".wallpaper.jpg"
            ".lock.jpg"
          ];
      };
  };

  personaj.work.simplerisk.enable = osConfig.profile.specialisations.work.simplerisk.indicator;

  programs = {
    feh.enable = true;
    joplin-desktop = {
      enable = true;
      general.editor = "hx";
      sync = {
        target = "file-system";
        interval = "5m";
      };
      extraConfig = {
        "sync.target" = 2;
        "sync.2.path" = "${config.home.homeDirectory}/Dokumentujo/Privata/Joplin";
        "editor.spellcheckBeta" = true;
        "spellChecker.languages" = [
          "pt-BR"
          "en-US"
          "es-ES"
        ];
      };
    };
    ssh = {
      enable = true;
      matchBlocks = {
        surtsey = {
          user = "marx";
          hostname = obtainIPV4Address "surtsey" "brume";
          identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/devices/surtsey" ];
        };
        grimsnes = {
          user = "marx";
          hostname = obtainIPV4Address "grimsnes" "brume";
          identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/devices/servers" ];
        };
        arenal = {
          user = "bjorn";
          hostname = obtainIPV4Address "arenal" "activos";
          identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/id" ];
        };
        irazu = {
          user = "bjorn";
          hostname = obtainIPV4Address "irazu" "activos";
          identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/id" ];
        };
      };
    };
    zed-editor = {
      enable = true;
      userSettings = {
        features = {
          copilot = false;
        };
        telemetry = {
          metrics = false;
        };
        vi-mode = true;
      };
    };
  };

  services.syncthing.enable = true;

  sops = {
    defaultSopsFile = ../secrets.yaml;
    #gnupg.home = "${config.home.homeDirectory}/.gnupg";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      "github_pat/nixpkgs-review" = {
        mode = "0700";
        path = "${config.home.homeDirectory}/.nixpkgs-review";
      };
      "pypi_tokens/python_trovo" = {
        mode = "0700";
        path = "${config.home.homeDirectory}/.pypi_python_trovo";
      };
    };
  };
}
