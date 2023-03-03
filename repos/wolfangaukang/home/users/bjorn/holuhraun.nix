{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

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

  # Personal Settings
  defaultajAgordoj = {
    gui.extraPkgs = with pkgs; [
      gimp
      musescore
      qbittorrent
    ];
    gaming = {
      enable = true;
      enableProtontricks = false;
      retroarch = {
        enable = true;
        package = pkgs.retroarch;
        coresToLoad = with pkgs.libretro; [
          mgba
          bsnes-mercury-performance
        ];
      };
    };
  };

  programs.neofetch.startOnZsh = true;
}
