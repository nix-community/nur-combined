{ pkgs }:

with { inherit (pkgs) callPackage; };

{
  dssim = callPackage ./pkgs/dssim { };

  pianoteq-stage = callPackage ./pkgs/pianoteq-stage { };

  wl-clipboard-x11 = callPackage ./pkgs/wl-clipboard-x11 { };
}
