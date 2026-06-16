{ }:
_: prev:
let
  libs = import ../libs {
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
  };
in
prev // libs
