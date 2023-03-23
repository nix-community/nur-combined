{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    #INTERNET
    wget
    bind.dnsutils
    whois
    nfs-utils

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

    # Security
    openssl
    apg

    # Markdown
    glow

    #help
    cheat

    # data tools
    sq # Swiss army knife for data
    jq
    yj

    # GRAPHIC
    imagemagick

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

    ruby
    rake

    trash-cli
  ];
}
