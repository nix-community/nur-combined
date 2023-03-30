{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "pim";
  home.homeDirectory = "/home/pim";
  home.stateVersion = "22.05";

  imports = [
    ./files-main
    ./conf-cli/fzf.nix
    ./conf-cli/git.nix
    ./conf-cli/tmux.nix
    ./conf-cli/vim.nix
    ./conf-cli/zsh.nix
  ];
}
