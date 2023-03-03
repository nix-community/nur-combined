{ config, pkgs, lib, inputs, ... }:

let
  user = "bjorn";
  inherit (inputs) self;

in
{
  imports = [
    "${self}/home/profiles/configurations/fonts.nix"
    "${self}/home/profiles/configurations/layouts.nix"
    "${self}/home/profiles/programs/syncthing.nix"
    "${self}/home/profiles/programs/shells/zsh.nix"
    "${self}/home/profiles/programs/nixos/alacritty.nix"
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "20.09";
  };

  xdg = {
    #enable = true;
    userDirs = {
      createDirectories = true;
      desktop = "\$HOME/Surtabla";
      documents = "\$HOME/Dokumentujo";
      download = "\$HOME/Elsxutujo";
      music = "\$HOME/Muzikujo";
      pictures = "\$HOME/Bildujo";
      publicShare = "\$HOME/Publika";
      templates = "\$HOME/Sxablonujo";
      videos = "\$HOME/Filmetujo";
      extraConfig = {
        XDG_DEVICE_DIR = "\$HOME/Aparatoj";
        XDG_MISC_DIR = "\$HOME/Utilecoj";
      };
    };
  };

  # Personal Settings
  defaultajAgordoj = {
    cli.enable = true;
    gui = {
      enable = true;
      browsers.chromium.enable = true;
      extraPkgs = with pkgs; [ discord spotify ];
    };
    dev.enable = true;
  };

  programs = {
    neofetch.enable = true;
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
