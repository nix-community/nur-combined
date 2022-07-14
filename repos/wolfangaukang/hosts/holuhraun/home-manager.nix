{ config, pkgs, ... }:

{
  imports = [
    ../../profiles/home-manager/common/syncthing.nix
    ../../profiles/home-manager/common/tmux.nix
    ../../profiles/home-manager/sets/general.nix
    ../../profiles/home-manager/nixos/alacritty.nix
    ../../profiles/home-manager/nixos/zsh.nix
  ];

  defaultajAgordoj = {
    cli.enable = true;
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
    neofetch = {
      enable = true;
      startOnZsh = true;
    };
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

  home = {
    packages = with pkgs; [
      # Personal GUI
      discord
      # Music
      musescore

      # Not needed rn
      # gnome3.cheese shotwell gnome3.pomodoro

      # Special
      #(callPackage ../../pkgs/signumone-ks/default.nix { }) # Signumone-ks
      #(callPackage ../../pkgs/upwork/default.nix { }) # Upwork 
      (callPackage ../../pkgs/stremio/default.nix { }) # Stremio
    ];
  };
}
