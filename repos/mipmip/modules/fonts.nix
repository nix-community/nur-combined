{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
      awesome
      dejavu_fonts
  ];

}

