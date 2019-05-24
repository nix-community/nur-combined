{ pkgs }:

with { inherit (pkgs) callPackage; };

{
  aerc = callPackage ./pkgs/aerc { };

  dssim = callPackage ./pkgs/dssim { };

  elvish = callPackage ./pkgs/elvish { };

  iosevka-comp-lig = callPackage ./pkgs/iosevka-comp-lig { };

  pianoteq-stage = callPackage ./pkgs/pianoteq-stage { };

  wl-clipboard-x11 = callPackage ./pkgs/wl-clipboard-x11 { };
}
