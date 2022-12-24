{ config, pkgs, ... }:

let
  stremio = 
    let
      inherit (pkgs) callPackage;
    in (callPackage ../../../pkgs/stremio/default.nix { });

  # VDHCoApp testing
  #vdhcoapp_testing = with pkgs; [
  #  chromium google-chrome vivaldi
  #];

in rec {
  imports = [
    ./common.nix

    ../../profiles/common/ranger.nix
  ];

  home.packages = [ stremio ];

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