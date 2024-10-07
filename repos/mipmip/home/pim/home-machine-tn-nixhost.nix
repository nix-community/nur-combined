{ lib, config, pkgs, bmc, race, jsonify-aws-dotfiles, dirtygit, shellstuff, ... }:

let
  system = "x86_64-linux";
in
{
  imports = [
    ./_hm-modules
    ./_roles/home-base-all.nix
  ];

  home.packages = [
    pkgs.gnumake
    pkgs.gcc
    pkgs.pkg-config
    pkgs.gum
    pkgs.granted
    pkgs.smug
    #pkgs.mipmip_pkg.shellstuff
    shellstuff.packages."${system}".shellstuff
    bmc.packages."${system}".bmc
    race.packages."${system}".race
    dirtygit.packages."${system}".dirtygit
    jsonify-aws-dotfiles.packages."${system}".jsonify-aws-dotfiles
  ];
}

