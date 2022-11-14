{ config, pkgs, ... }:

rec {
  imports = [ ./common.nix ];

  home.packages = with pkgs; [ musescore ];

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