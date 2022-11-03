{ system, lib, pkgs, ... }:
with lib;
let
  inherit (pkgs) callPackage;
  vpp-pkgs = callPackage ./vpp {};
in
rec {
  # TODO: More packages!
} // optionalAttrs (!hasSuffix "-darwin" system) rec {
  # Packages that won't run on Darwin.
  inherit (vpp-pkgs) vpp vpp_papi;
  vppcfg = callPackage ./vppcfg { inherit vpp_papi; };
}

