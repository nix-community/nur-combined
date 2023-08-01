{ config, lib, pkgs, ... }:

let
  fontsList = with pkgs; [
    meslo-lg
    awesome
    dejavu_fonts
    open-sans
    inter
    rubik
  ];
in
{
  environment.systemPackages = fontsList;
  fonts.fonts = fontsList;
}

