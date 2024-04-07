{ pkgs, ... }:
{
  imports = [ ../base/default.nix ];
  home.packages = with pkgs; [
    nix-option
    custom.neovim
    custom.emacs
    htop
    pkg
    # some defaults on the default dotfile
    hostname
    gnugrep
    gnused
    gnutar
    gzip
    xz
    zip
    unzip
  ];
}
