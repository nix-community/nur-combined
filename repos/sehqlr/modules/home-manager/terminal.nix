{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [ httpie nix-prefetch-scripts ripgrep ];

  programs.bat.enable = true;

  programs.command-not-found.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.htop.enable = true;

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

  programs.termite.enable = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mouse on
    '';
    terminal = "tmux-256color";
    shortcut = "a";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "copyfile" "extract" "httpie" "pass" "sudo" "systemd" ];
      theme = "af-magic";
    };
    shellAliases = { nixos = "sudo nixos-rebuild"; };
  };
}
