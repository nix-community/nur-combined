{
  pkgs ? import <nixpkgs> { },
}:
let
  nurPkgs = import ./. { inherit pkgs; };
in
{
  cacheOutputs = [
    nurPkgs.beurer_bf100_parser
    nurPkgs.npupnp
    nurPkgs.libupnpp
    nurPkgs.upplay
    nurPkgs.eezupnp
    nurPkgs.betterbird-bin
    nurPkgs.czkawka-git
    nurPkgs.birt-designer
  ];
}
