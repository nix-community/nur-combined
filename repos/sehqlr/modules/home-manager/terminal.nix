{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [
    httpie
    nix-prefetch-scripts
    ripgrep
  ];

  programs.bat.enable = true;

  programs.broot.enable = true;

  programs.command-not-found.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.htop.enable = true;

  programs.jq.enable = true;

  programs.lf.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[λ](bold green)";
        error_symbol = "[λ](bold red)";
      };
    };
  };

  programs.termite = { enable = true; };

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mouse on
    '';
    plugins = with pkgs; [{
      plugin = tmuxPlugins.tmux-colors-solarized;
      extraConfig = ''
        set -g @colors-solarized 'dark'
        set -g status-right ""
      '';
    }];
    terminal = "tmux-256color";
    shortcut = "a";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "httpie" "ipfs" "ripgrep" "sudo" "systemd" "tmux" ];
      theme = "af-magic";
    };
    shellAliases = {
      cat = "bat";
      nixos = "sudo nixos-rebuild";
    };
  };
}
