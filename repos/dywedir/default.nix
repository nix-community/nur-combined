{ pkgs }:

with { inherit (pkgs) callPackage; };

{
  iosevka-comp-lig = callPackage ./pkgs/iosevka-comp-lig {};

  pianoteq-stage = callPackage ./pkgs/pianoteq-stage { };
}
