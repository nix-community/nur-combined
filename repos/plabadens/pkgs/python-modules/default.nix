{ pkgs, pythonPackages }:

let
  callPackage = pythonPackages.callPackage;
in {
  edmarketconnector = callPackage ./edmarketconnector { };

  obspy = callPackage ./obspy { };
}
