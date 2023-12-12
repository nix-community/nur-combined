{ config, lib, pkgs, unstable, ... }:

{
  environment.sessionVariables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    ctags
    sc-im
    git-sync
    gitFull
    unstable.neovim

    ruby # for Linny
  ];
}
