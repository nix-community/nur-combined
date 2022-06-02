{ config, pkgs, lib, ... }:

let
  nur_pkgs = with pkgs.nur.repos.wolfangaukang; [ vdhcoapp ];
  upstream_pkgs = with pkgs; [
    # Personal GUI
    discord

    # Special
    (callPackage ../../pkgs/stremio/default.nix { }) # Stremio

    # Testing for vdhcoapp
    # chromium google-chrome vivaldi
  ];

in
{
  imports = [
    ../../modules/home-manager/personal.nix
    ../../profiles/home-manager/sets/dev.nix
    ../../profiles/home-manager/sets/general.nix
    ../../profiles/home-manager/common/ranger.nix
    ../../profiles/home-manager/common/syncthing.nix
    ../../profiles/home-manager/common/tmux.nix
    ../../profiles/home-manager/nixos/alacritty.nix
    ../../profiles/home-manager/nixos/zsh.nix
  ];

  home.packages = nur_pkgs ++ upstream_pkgs;

  defaultajAgordoj.gui = {
    enable = true;
    browsers.chromium.enable = true;
  };

  programs = {
    neofetch.enable = true;
    sab = {
      enable = true;
      bots = {
        trovo = {
          settingsPath = "/home/bjorn/Projektujo/Python/stream-alert-bot/etc/settings-trovo.yml";
          consumerType = "trovo";
        };
        twitch = {
          settingsPath = "/home/bjorn/Projektujo/Python/stream-alert-bot/etc/settings-twitch.yml";
          consumerType = "twitch";
        };
      };
    };
  };
}

