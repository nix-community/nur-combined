{
  pkgs ? import <nixpkgs> { },
}:

let
  npupnp = pkgs.callPackage ./pkgs/npupnp { };
  libupnpp = pkgs.callPackage ./pkgs/libupnpp { inherit npupnp; };
in
{
  inherit npupnp libupnpp;
  upplay = pkgs.callPackage ./pkgs/upplay {
    inherit libupnpp;
  };
  eezupnp = pkgs.callPackage ./pkgs/eezupnp { };
  betterbird-bin = pkgs.callPackage ./pkgs/betterbird-bin { };
  czkawka-git = pkgs.callPackage ./pkgs/czkawka-git { };
}
