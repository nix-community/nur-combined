{ pkgs, ... }:

{
  environment.packages = with pkgs; [ 
    vim
    subversion
    git
  ];
  system.stateVersion = "23.05";

  home-manager.config = {
    imports = [
      #../programs/git.nix
      #../programs/lf/default.nix
      #../programs/neovim.nix
      #../programs/bash.nix
    ];
    #home.stateVersion = "22.11";
    home.stateVersion = "22.05";
  };
}
