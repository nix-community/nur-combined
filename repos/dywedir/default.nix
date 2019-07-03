{ pkgs }:

with { inherit (pkgs) callPackage; };

{
  dssim = callPackage ./pkgs/dssim { };

  iosevka-comp-lig = callPackage ./pkgs/iosevka-comp-lig { };

  janetsh = callPackage ./pkgs/janetsh { };

  pianoteq-stage = callPackage ./pkgs/pianoteq-stage { };

  wl-clipboard-x11 = callPackage ./pkgs/wl-clipboard-x11 { };
}
