{
  inputs,
  lib,
  localLib,
  pkgs,
  ...
}:

let
  inherit (inputs) self;
  profiles = localLib.getNixFiles "${self}/home/users/bjorn/profiles/" [
    "workstation"
    "starship"
    "zsh"
  ];

in
{
  imports = profiles ++ [ "${self}/home/users/bjorn" ];

  home = {
    packages = with pkgs; [
      darwin-rebuild
    ];
    stateVersion = "25.11";
  };

  programs = {
    fish.enable = lib.mkForce false;
    kitty.font.size = lib.mkForce 12;
    zsh.enable = true;
  };
}
