{ config, pkgs, username, homedir, ... }:

{
  programs.home-manager.enable = true;
  home.username = username;
  home.homeDirectory = homedir;
  home.stateVersion = "22.05";

  imports = [
    ./files-main
    ./conf-cli/fzf.nix
    ./conf-cli/nnn.nix
    ./conf-cli/git.nix
    ./conf-cli/tmux.nix
    ./conf-cli/vim.nix
    ./conf-cli/atuin.nix
    #./conf-cli/neovim.nix
    ./conf-cli/zsh.nix
    ./conf-cli/awscli.nix
  ];
}
