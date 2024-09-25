{ config, lib, pkgs, unstable, ... }:

{

  environment.systemPackages = with pkgs; [
    texlive.combined.scheme-full
    pandoc

    quarto
    jupyter
    python311Packages.numpy
  ];
}

