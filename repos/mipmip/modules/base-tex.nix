{ config, lib, pkgs, unstable, ... }:

{

  environment.systemPackages = with pkgs; [
    texlive.combined.scheme-full
    pandoc

    quarto
    librsvg
    jupyter

    python311Packages.numpy
  ];
}

