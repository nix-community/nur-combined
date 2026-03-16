{
  nixpkgs ? <nixpkgs>,
}:
_: prev:
let
  libs = import ../libs {
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
  };
  pure = import ../libs/pure.nix {
    inherit nixpkgs;
    systems = [ prev.stdenv.buildPlatform.system ];
  };
in
prev // libs // pure
