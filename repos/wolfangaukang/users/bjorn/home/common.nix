{ config, pkgs, lib, ... }:

let
  user = "bjorn";
  nur_pkgs = with pkgs.nur.repos.wolfangaukang; [ vdhcoapp ];
  upstream_pkgs = with pkgs; [
    # GUI
    discord
  ];

in
{
  imports = [
    ../../../profiles/home-manager/common/fonts.nix
    ../../../profiles/home-manager/common/layouts.nix
    ../../../profiles/home-manager/common/syncthing.nix
    ../../../profiles/home-manager/common/tmux.nix
    ../../../profiles/home-manager/nixos/alacritty.nix
    ../../../profiles/home-manager/nixos/zsh.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "20.09";
    packages = nur_pkgs ++ upstream_pkgs;
  };

  # Personal Settings
  defaultajAgordoj.cli.enable = true;

  programs.neofetch.enable = true;
}