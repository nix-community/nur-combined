{ pkgs, ... }:

final: prev:

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  debugpy = callPackage ./debugpy { };

  pygls_1 = callPackage ./pygls/1.nix {
    lsprotocol = prev.lsprotocol_2023;
  };

  pygls_2 = callPackage ./pygls/2.nix {
    lsprotocol = prev.lsprotocol_2025;
  };

  pygls = final.pygls_1;

  pytest-datadir = callPackage ./pytest-datadir { };

  vdf = callPackage ./vdf { };
}
