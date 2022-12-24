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
    ../../profiles/common/fonts.nix
    ../../profiles/common/layouts.nix
    ../../profiles/common/syncthing.nix
    ../../profiles/common/tmux.nix
    ../../profiles/nixos/alacritty.nix
    ../../profiles/nixos/zsh.nix
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