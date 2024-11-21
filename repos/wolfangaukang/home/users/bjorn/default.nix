{ config, pkgs, ... }:

{
  imports = [
    ./modules

    ./profiles/dev.nix
    ./profiles/fonts.nix
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

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
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
        helix = {
          enable = true;
          default = true;
        };
        neovim.enable = true;
      };
    };
    gui = {
      enable = true;
      terminal = {
        font = {
          family = "MesloLGS NF";
          package = pkgs.meslo-lgs-nf;
        };
        kitty = {
          enable = true;
          theme = "Black Metal";
        };
      };
      extraPkgs = with pkgs; [
        calibre
        keepassxc
        libreoffice
        mpv
        mupdf
        multifirefox
        ranger
        raven-reader
        sigil
        thunderbird
      ];
      vscode.enable = true;
      browsers.chromium.enable = true;
    };
  };
}
