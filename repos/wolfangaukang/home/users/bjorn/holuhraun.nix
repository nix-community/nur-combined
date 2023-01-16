{ config, pkgs, ... }:

rec {
  imports = [ ./common.nix ];

  home = {
    packages = with pkgs; [ musescore ];
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
  };

  # Personal Settings
  defaultajAgordoj = {
    gui = {
      enable = true;
      browsers.chromium.enable = true;
    };
    dev.enable = true;
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

  programs = {
    neofetch.startOnZsh = true;
    # TODO: Handle this on a external file
    sab = {
      enable = true;
      bots = {
        trovo = {
          settingsPath = "${config.home.homeDirectory}/Projektujo/Python/stream-alert-bot/etc/settings-trovo.yml";
          consumerType = "trovo";
        };
        twitch = {
          settingsPath = "${config.home.homeDirectory}/Projektujo/Python/stream-alert-bot/etc/settings-twitch.yml";
          consumerType = "twitch";
        };
      };
    };
  };
}
