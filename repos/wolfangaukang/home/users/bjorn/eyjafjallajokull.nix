{ config, pkgs, inputs, ... }:

  # VDHCoApp testing
  #vdhcoapp_testing = with pkgs; [
  #  chromium google-chrome vivaldi
  #];

let
  inherit (inputs) self;

in {
  imports = [
    ./common.nix

    "${self}/home/profiles/programs/ranger.nix"
  ];

  defaultajAgordoj.gui.extraPkgs = with pkgs; [ stremio ];
}
