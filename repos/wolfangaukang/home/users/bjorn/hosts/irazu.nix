{ inputs
, pkgs
, osConfig
, localLib
, hostname
, lib
, ...
}:

let
  inherit (inputs) self;
  profiles = localLib.getNixFiles "${self}/home/users/bjorn/profiles/" [ "sway" "workstation" ];
  hostInfo = localLib.getHostDefaults hostname;
  mainDisplay =  hostInfo.display.id;

in
{
  imports = profiles ++ [
    "${self}/home/users/bjorn"
    "${self}/home/users/bjorn/profiles/programs/mopidy.nix"
  ];

  home = {
    packages = with pkgs; [
      gimp
      musescore
      qbittorrent
    ];
    persistence = {
      #"/persist/home/bjorn" = {
      #  directories = [
      #    ".aws"
      #    #".cache"
      #    ".config"
      #    ".gnupg"
      #    ".local"
      #    ".mozilla"
      #    ".ssh/keys"
      #    #".thunderbird"
      #    #".vscode-oss"
      #  ];
      #  files = [
      #    ".nixpkgs-review"
      #    ".ssh/known_hosts"
      #  ];
      #};
      "/data/bjorn" = {
        directories = [
          "Aparatoj"
          "Biblioteko"
          "Bildujo"
          "Dokumentujo"
          "Ludoj"
          "Muzikujo"
          "Projektujo"
          "Screenshots"
          "Torrentoj"
          "Utilecoj"
          "VMs"
        ];
      };
    };
  };

  personaj = {
    gaming =
      let
        customRetroarch = (pkgs.retroarch.withCores (cores: with cores; [
          mgba
          bsnes-mercury-performance
        ]));
      in {
        enable = osConfig.profile.specialisations.gaming.indicator;
        enableProtontricks = true;
        extraPkgs = with pkgs; [
          heroic
          customRetroarch
        ];
      };
  };

  programs.kitty.font.size = lib.mkForce 10;
}
