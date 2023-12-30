{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neofetch
    tldr
    cheat
    httpie
    xh

    fd

    # includes vidir
    moreutils

    # disk
    duf

    dstp # Run common networking tests against your site

    #cli preview stuff for nnn
    bat
    libarchive # Provides bsdtar and support for more archive formats
    pmount # For mounting disks
    udisks # For mounting disks
    xdragon # Drag and drop utility
    ffmpegthumbnailer # video thumbnails
    poppler_utils # pdf thumbnails
    catimg
    #gnome-epub-thumbnailer # epub thumbnails
    fontpreview # font previews
    w3m # html preview

  ];
}
