{ pkgs, ... }:

final: prev:

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  xpadneo = callPackage ./xpadneo { };
}
