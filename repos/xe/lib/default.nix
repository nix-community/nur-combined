{ pkgs }:

with pkgs.lib; {
  dockerImage = import ./dockerImage.nix;

  srcNoTarget = dir:
    builtins.filterSource
    (path: type: type != "directory" || builtins.baseNameOf path != "target")
    dir;

  zigNightly = import ./zigNightly.nix {
    fetchurl = pkgs.fetchurl;
    stdenv = pkgs.stdenv;
  };
}

