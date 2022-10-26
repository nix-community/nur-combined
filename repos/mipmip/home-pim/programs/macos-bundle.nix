{ config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.awscli
    pkgs.git
    pkgs.htop
    pkgs.hugo
    pkgs.jq
    pkgs.terraform
    pkgs.tldr
    pkgs.yarn
    pkgs.yq
  ];
}
