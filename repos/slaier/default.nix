{ pkgs ? import <nixpkgs> { } }:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
  callPackage = path: overrides: pkgs.callPackage path
    { inherit sources; } // overrides;
in
{
  material-fox = callPackage ./pkgs/material-fox { };
  arkenfox-userjs = callPackage ./pkgs/arkenfox-userjs { };
  clash-speedtest = callPackage ./pkgs/clash-speedtest { };
} // (import ./pkgs/vscode-extensions { inherit pkgs sources; })

