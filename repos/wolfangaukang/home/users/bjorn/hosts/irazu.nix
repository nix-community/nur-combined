{ inputs
, pkgs
, config
, osConfig
, localLib
, hostname
, ...
}:

let
  inherit (inputs) self;
  inherit (localLib) getHostDefaults;
  hostInfo = getHostDefaults hostname;
  mainDisplay =  hostInfo.display.id;

in
{
  imports = [
    "${self}/home/users/bjorn"
    "${self}/home/users/bjorn/profiles/workstation.nix"
    "${self}/home/users/bjorn/profiles/programs/mopidy.nix"
    "${self}/home/users/bjorn/profiles/sway.nix"
  ];

  home.persistence = {
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

  defaultajAgordoj = {
    gaming = {
      enable = osConfig.profile.specialisations.gaming.indicator;
      enableProtontricks = true;
      retroarch = {
        enable = true;
        package = pkgs.retroarch;
        coresToLoad = with pkgs.libretro; [
          mgba
          bsnes-mercury-performance
        ];
      };
      extraPkgs = with pkgs; [ heroic ];
    };
    gui.terminal.font.size = 10;
  };

  # Personal Settings
  home.packages = with pkgs; [
    gimp
    musescore
    qbittorrent
  ];
}
