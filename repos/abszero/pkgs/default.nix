{ pkgs }:

let
  extLib = pkgs.lib.extend
    (_: prev: { abszero = import ../lib { lib = prev; }; });
  extPkgs = pkgs.extend (_: _: { lib = extLib; });
  pkgsByName = extLib.abszero.filesystem.toPackages extPkgs ./.;
in

pkgsByName // {
  vscode-insiders-with-extensions =
    extPkgs.vscode-with-extensions.override {
      vscode = pkgsByName.vscode-insiders;
    };
}
