{ config, pkgs, ... }: {
  imports = [ ./dev ./email ];

  home.packages = with pkgs; [
    gnupg
    gpa

    file
    nixfmt
    pandoc
    ripgrep
    w3m
    xclip
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
    theme = "lb"; # rofi-theme-selector
  };

  programs.password-store.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      prompt_order = [
        "nix_shell"
        "git_branch"
        "git_commit"
        "git_state"
        "git_status"
        "line_break"
        "character"
      ];
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
}
