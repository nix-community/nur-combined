{
  pkgs ? import <nixpkgs> { },
}:

let
  myPkgs = pkgs.extend (import ./overlays);
in
{
  overlays = import ./overlays;
  inherit (myPkgs) omp;
}
