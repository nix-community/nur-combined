{ config, lib, pkgs, ... }: {
  imports = [
    ./email.nix
    ./git.nix
    ./gpg.nix
    ./kakoune.nix
    ./lorri.nix
    ./sway.nix
    ./streaming.nix
    ./terminal.nix
  ];

  programs.home-manager.enable = true;

  home.username = "sam";
  home.homeDirectory = "/home/sam";

  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;
}
