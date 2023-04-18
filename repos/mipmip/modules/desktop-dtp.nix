{ config, lib, pkgs, unstable, ... }:

{

  environment.systemPackages = with pkgs; [

    # PDF
    zathura
    pdftk
    pdfarranger
    paperwork # could replace papermerge

    gimp
    inkscape-with-extensions
    feh
    swappy

    emulsion-palette

    blender

    libreoffice

    nextcloud-client

  ];
}
