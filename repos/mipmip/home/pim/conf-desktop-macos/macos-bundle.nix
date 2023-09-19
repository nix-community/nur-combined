## ALL PACKAGES NOT HERE ARE IN ../files-macos/Brewfile
{ config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.git
    pkgs.htop
    pkgs.hugo
    pkgs.jq
    pkgs.tldr

    #ADEVINTA
    pkgs.awscli
    pkgs.tfswitch
    pkgs.terraform-docs

    pkgs.yarn
    pkgs.yq
    pkgs.smug
    pkgs.unixtools.watch
    pkgs.git-sync
    pkgs.silver-searcher
    pkgs.fzf
    pkgs.apg
    pkgs.smug
    pkgs.ctags
    pkgs.tmux
  ];
}
