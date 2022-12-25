{ config, pkgs, ... }:

  # VDHCoApp testing
  #vdhcoapp_testing = with pkgs; [
  #  chromium google-chrome vivaldi
  #];

rec {
  imports = [
    ./common.nix

    ../../profiles/common/ranger.nix
  ];

  home.packages = with pkgs; [ stremio ];

  defaultajAgordoj = {
    gui = {
      enable = true;
      browsers.chromium.enable = true;
    };
    dev.enable = true;
  };

  programs = {
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