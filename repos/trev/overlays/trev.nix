{
  nixpkgs ? <nixpkgs>,
}:
_: prev:
let
  nur = import ../. {
    inherit nixpkgs;
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
  };
in
{
  trev = nur;
}
