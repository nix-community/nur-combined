{ pkgs, pythonPackages }:

let
  callPackage = pythonPackages.callPackage;
in {
  obspy = callPackage ./obspy { };
}
