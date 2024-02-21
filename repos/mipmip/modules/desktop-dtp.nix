{ config, lib, pkgs, nixpkgs-inkscape13, ... }:

{

  environment.systemPackages = with pkgs; [

    # PDF
    zathura
    pdftk
    pdfarranger
    paperwork # could replace papermerge

    gimp
    nixpkgs-inkscape13.inkscape-with-extensions
    #nixpkgs-inkscape13.inkscape
    feh
    swappy

    emulsion-palette

    blender

    libreoffice

    nextcloud-client
    syncthing

  ];
}
