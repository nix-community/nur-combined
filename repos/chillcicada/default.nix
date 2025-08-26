{
  pkgs ? import <nixpkgs> { },
}:

let
  byName = builtins.readDir ./pkgs/by-name;
  pkgsByName = builtins.mapAttrs (name: _: pkgs.callPackage (./pkgs/by-name + "/${name}") { }) byName;
in

{ } // pkgsByName
