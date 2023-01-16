{ config, pkgs, ... }:

  # VDHCoApp testing
  #vdhcoapp_testing = with pkgs; [
  #  chromium google-chrome vivaldi
  #];

{
  imports = [
    ./common.nix

    ../../profiles/common/ranger.nix
  ];

  home.packages = with pkgs; [ stremio ];
}