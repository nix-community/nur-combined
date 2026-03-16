{ }:
_: prev:
let
  packages = import ../packages {
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
  };
in
prev // packages
