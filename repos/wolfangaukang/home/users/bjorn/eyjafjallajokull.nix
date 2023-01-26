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

  defaultajAgordoj.gui.extraPkgs = with pkgs; [ stremio ];
}