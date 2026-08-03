{
  pkgs ? import <nixpkgs> { },
}:

{
  ff00-vwm = pkgs.callPackage ./pkgs/ff00-vwm { };
}
