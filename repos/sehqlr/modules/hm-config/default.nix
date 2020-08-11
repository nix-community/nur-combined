{ config, pkgs, ... }: {
  imports = [ ./email ];

  home.packages = with pkgs; [
    file
    gnupg
    gpa
    httpie
    nixfmt
    pandoc
    ripgrep
    w3m
    xclip

    python37Packages.editorconfig
  ];

  nixpkgs.config.allowUnfree = true;

  programs.bat.enable = true;

  programs.command-not-found.enable = true;

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.feh.enable = true;
  programs.zathura.enable = true;

  programs.htop.enable = true;

  programs.rofi = {
    enable = true;
    # package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji pkgs.rofi-pass ]; };
    theme = "lb"; # rofi-theme-selector
  };

  programs.password-store.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character.symbol = "λ";
    };
  };
  programs.termite.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.plugins =
      [ "copyfile" "extract" "httpie" "pass" "sudo" "systemd" ];
    oh-my-zsh.theme = "af-magic";
    shellAliases.nixos = "sudo nixos-rebuild";
  };

  services.flameshot.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "3759E9087871E845B0621E00F6BE8F0DE65D9666" ];
  };

  xsession.windowManager.xmonad.enable = true;
  xsession.windowManager.xmonad.enableContribAndExtras = true;
  xesssion.windowManager.xmonad.config = ./xmonad.hs;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.kakoune.enable = true;
  programs.kakoune.config = {
    colorScheme = "solarized-dark";
    hooks = [{
      name = "WinCreate";
      option = "^[^*]+$";
      commands = "editorconfig-load";
    }];
    numberLines.enable = true;
    showWhitespace.enable = true;
    ui.enableMouse = true;
  };

  programs = {
    git = {
      enable = true;
      aliases = {
        graph = "log --graph --oneline --decorate";
        staged = "diff --cached";
      };
      ignores = [ "result" "*~" ".#*" ];
      signing.key = "hey@samhatfield.me";
      signing.signByDefault = true;
      userEmail = "hey@samhatfield.me";
      userName = "sehqlr";
      extraConfig = { init = { defaultBranch = "main"; }; };
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "github" = {
          host = "github.com";
          user = "git";
        };
        "gitlab" = {
          host = "gitlab.com";
          user = "git";
        };
        "sr.ht" = { host = "*sr.ht"; };
        "bytes.zone" = {
          host = "git.bytes.zone";
          user = "git";
          port = 2222;
        };
      };
    };
  };
  services.lorri.enable = true;
}

