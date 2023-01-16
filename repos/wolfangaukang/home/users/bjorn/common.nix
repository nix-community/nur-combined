{ config, pkgs, lib, ... }:

let
  user = "bjorn";
  nur_pkgs = with pkgs.nur.repos.wolfangaukang; [ vdhcoapp ];
  upstream_pkgs = with pkgs; [
    # GUI
    discord
  ];

in
{
  imports = [
    ../../profiles/common/fonts.nix
    ../../profiles/common/layouts.nix
    ../../profiles/common/syncthing.nix
    ../../profiles/common/tmux.nix
    ../../profiles/nixos/alacritty.nix
    ../../profiles/nixos/zsh.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "20.09";
    packages = nur_pkgs ++ upstream_pkgs;
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
    };
    dev.enable = true;
  };

  programs = {
    neofetch.enable = true;
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