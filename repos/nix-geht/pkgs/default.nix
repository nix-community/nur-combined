{ system, lib, pkgs, ... }:
with lib;
let
  inherit (pkgs) callPackage;

  vpp-pkgs = callPackage ./vpp {};
  shinyblink = callPackage ./shinyblink {};
in
rec {
  # TODO: More packages!
  inherit (shinyblink) ffshot ff-overlay ff-sort ff-glitch ff-notext;
} // optionalAttrs (!hasSuffix "-darwin" system) rec {
  # Packages that won't run on Darwin.
  inherit (vpp-pkgs) vpp vpp_papi;
  vppcfg = callPackage ./vppcfg { inherit vpp_papi; };
}

