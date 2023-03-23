{ config, lib, pkgs, ... }:

{
  environment.sessionVariables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    ctags
    sc-im
    git-sync
    gitFull
    neovim
  ];
}
