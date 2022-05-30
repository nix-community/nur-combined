{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    meslo-lg
    awesome
    dejavu_fonts
  ];

}

