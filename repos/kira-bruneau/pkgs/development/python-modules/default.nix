{ pkgs, ... }:

final: prev:

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  debugpy = callPackage ./debugpy { };

  pygls = callPackage ./pygls {
    lsprotocol = prev.lsprotocol_2025;
  };

  pytest-datadir = callPackage ./pytest-datadir { };

  vdf = callPackage ./vdf { };
}
