{ config, lib, pkgs, ... }:
{
  imports = [
    ./code.nix
    ./neovim.nix
    ./emacs.nix
  ];
}