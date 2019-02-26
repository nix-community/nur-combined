{ pkgs }:

with { inherit (pkgs) callPackage; };

{
  elvish = callPackage ./pkgs/elvish { };

  iosevka-comp-lig = callPackage ./pkgs/iosevka-comp-lig {};

  pianoteq-stage = callPackage ./pkgs/pianoteq-stage { };
}
