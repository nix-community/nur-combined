{ inputs
, pkgs
, osConfig
, ...
}:

let
  inherit (inputs) self;

in
{
  imports = [
    "${self}/home/users/bjorn"
    "${self}/home/users/bjorn/profiles/workstation.nix"
    "${self}/home/users/bjorn/profiles/programs/mopidy.nix"
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
    #    # TODO: Test using only .Upwork/Upwork/UserData/
    #    ".Upwork"
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
