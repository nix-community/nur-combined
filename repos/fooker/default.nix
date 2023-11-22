{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
, ...
}:

rec {
  jmxterm = pkgs.callPackage ./pkgs/jmxterm.nix { };
  hawtio = pkgs.callPackage ./pkgs/hawtio.nix { };

  udpgen = pkgs.callPackage ./pkgs/udpgen.nix { };

  studio-link = pkgs.callPackage ./pkgs/studio-link.nix { };
}

