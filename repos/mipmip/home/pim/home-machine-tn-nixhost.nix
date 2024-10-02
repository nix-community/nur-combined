{ lib, config, pkgs, bmc, race, jsonify-aws-dotfiles, dirtygit, ... }:

let
  system = "x86_64-linux";
in
{
  imports = [
    ./_hm-modules
    ./home-base-all.nix
  ];

  home.packages = [
    pkgs.neovim
    pkgs.gnumake
    pkgs.gcc
    pkgs.pkg-config
    pkgs.gum
    pkgs.granted
    pkgs.smug
    #pkgs.mipmip_pkg.shellstuff
    bmc.packages."${system}".bmc
    race.packages."${system}".race
    dirtygit.packages."${system}".dirtygit
    jsonify-aws-dotfiles.packages."${system}".jsonify-aws-dotfiles
  ];
}

