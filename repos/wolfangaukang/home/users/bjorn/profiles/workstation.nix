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
  inherit (pkgs.stdenv) hostPlatform;
  inherit (localLib) obtainIPV4Address;
  linux_specific = {
    home = {
      packages = with pkgs; [
        libreoffice
        multifirefox
        mupdf
        mpv
        newsflash
      ];
    };
    programs.feh.enable = true;
    # TODO: Enable sops for tenorio
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
  };

in
{
  imports = [
    ./chromium.nix
    ./firefox.nix
    ./kitty.nix
  ]
  ++ (lib.optionals hostPlatform.isLinux [ ./persistence.nix ]);

  config = lib.mkMerge [
    {
      home.packages = with pkgs; [
        telegram-desktop
        thunderbird
      ];

      personaj.work.simplerisk.enable =
        if hostPlatform.isLinux then osConfig.profile.specialisations.work.simplerisk.indicator else false;

      programs = {
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
      };

      services.syncthing.enable = true;
    }
    (lib.mkIf hostPlatform.isLinux linux_specific)
  ];
}
