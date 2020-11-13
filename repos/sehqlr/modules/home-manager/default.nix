{ config, lib, pkgs, ... }: {
  imports = [
    ./apps.nix
    ./email.nix
    ./git.nix
    ./gpg.nix
    ./kakoune.nix
    ./lorri.nix
    ./neuron.nix
    ./sway.nix
    ./terminal.nix
  ];

  programs.home-manager.enable = true;

  home.username = "sam";
  home.homeDirectory = "/home/sam";

  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
}
