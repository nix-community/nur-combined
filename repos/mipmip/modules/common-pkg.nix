{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    silver-searcher
    fzf
    bat
    apg
    glow
    mipmip_pkg.smug
    ctags
    git-lfs
    sc-im
    jq
    yj
    imagemagick
    python3Full
    python3Packages.pip
    python3Packages.setuptools
    openssl
    direnv
    zip
    unzip
  ]
  ++ (if pkgs.stdenv.isDarwin then
  [
    unixtools.watch
  ]
  else
  [
    telnet
    vifm
    wtf
    binutils
    gettext
    gcc
    ruby
    rake
    bind.dnsutils
    psmisc
    file
    pkg-config
    whois
    xorg.xkill
  ]
  );
}
