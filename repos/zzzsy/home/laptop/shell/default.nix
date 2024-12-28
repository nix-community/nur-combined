{ config, ... }:
{
  imports = [
    ./fish.nix
    ./git.nix
    ./kitty.nix
    ./starship.nix
  ];
  programs.eza = {
    enable = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    icons = "auto";
    git = true;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka ZT:size=12";
        dpi-aware = "yes";
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "everforest-dark";
      simplified-ui = true;
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "everforest-dark-medium";
    };
  };

  programs.tealdeer = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];
    settings = {
      sync_frequency = "15m";
      dialect = "us";
    };
  };
  programs.man.generateCaches = false;

  home.file.".config/neofetch/config.conf".text = import ./neofetch.nix;
  home.shellAliases = {
    pb = "curl -F 'c=@-' 'https://fars.ee/'";
    gst = "git status";
    n = "hyfetch";
    clc = "clear";
    ":q" = "exit";
    snvim = "EDITOR=nvim sudoedit";
    icat = "kitty +kitten icat";
    s = "kitten ssh";
  };
}
