{ lib, config, pkgs, bmc, jsonify-aws-dotfiles, dirtygit, ... }:

let
  system = "x86_64-linux";
in
{
  imports = [
    ./home-base-all.nix
  ];

  home.packages = [
    pkgs.neovim
    pkgs.gnumake
    pkgs.gcc
    pkgs.pkg-config
    pkgs.gum
    bmc.packages."${system}".bmc
    dirtygit.packages."${system}".dirtygit
    jsonify-aws-dotfiles.packages."${system}".jsonify-aws-dotfiles
  ];
}

