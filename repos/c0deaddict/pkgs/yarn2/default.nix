{ stdenv, pkgs }:

let

  nodePackages = import ./composition.nix {
    inherit pkgs;
    system = stdenv.hostPlatform.system;
  };

in

  nodePackages.yarn-berry
