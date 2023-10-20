{ config, lib, pkgs, nixpkgsinkscape13, ... }:

{

  environment.systemPackages = with pkgs; [

    # PDF
    zathura
    pdftk
    pdfarranger
    paperwork # could replace papermerge

    gimp
    nixpkgsinkscape13.inkscape-with-extensions
    #nixpkgsinkscape13.inkscape
    feh
    swappy

    emulsion-palette

    blender

    libreoffice

    nextcloud-client

  ];
}
