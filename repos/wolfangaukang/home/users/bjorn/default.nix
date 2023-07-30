{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./modules

    ./profiles/dev.nix
    ./profiles/fonts.nix

    "${inputs.hm-firejail}/modules/programs/firejail.nix"
  ];

  home = {
    username = "bjorn";
    homeDirectory = "/home/${config.home.username}";
    stateVersion = "23.05";

    packages = with pkgs; [
      bc
      htop
      p7zip
      peaclock
      tree
      shellcheck

    ];
  };

  # TODO: Review
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

  # Personal modules
  defaultajAgordoj = {
    cli = {
      enable = true;
      editors = {
        helix.enable = true;
        neovim = {
          enable = true;
          default = true;
        };
      };
    };
    # TODO: Review
    gui = {
      enable = true;
      extraPkgs = with pkgs; [
        calibre
        keepassxc
        libreoffice
        multifirefox
        raven-reader
        sigil
        thunderbird
        vlc
      ];
      vscode.enable = true;
      browsers.chromium.enable = true;
    };
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
