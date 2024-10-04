{ pkgs, ... }:

final: prev:

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  debugpy = callPackage ./debugpy { };

  pygls = callPackage ./pygls { };

  pytest-datadir = callPackage ./pytest-datadir { };

  vdf = callPackage ./vdf { };
}
