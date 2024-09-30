{ config, lib, pkgs, ... }:

{

  # TODO MOVE TO OWN SECTION
  nixpkgs.config.permittedInsecurePackages = [
    "libxls-1.6.2"
    "nix-2.15.3"
  ];

  environment.systemPackages = with pkgs; [

    #INTERNET
    wget
    bind.dnsutils
    whois
    nfs-utils
    mosh

    #SYSTEM
    htop
    util-linux
    sysstat
    iotop
    binutils
    gettext
    psmisc
    file

    # cli searchers
    silver-searcher
    fzf
    ripgrep

    # Security
    openssl
    apg

    # Markdown
    #glow

    #help
    cheat

    entr


    # GRAPHIC
    imagemagick
    imgp
    oxipng
    pngquant

    # PYthon
    python3Full
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.requests


    direnv

    # COMPRESS
    zip
    unzip

    # Filemanager
    vifm
    wtf

    gcc
    pkg-config

    trash-cli
  ];
}
