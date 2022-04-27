{ mkShell, linyinfeng, lint, update, nixpkgs-fmt, cabal-install, ormolu }:

let
  simple = mkShell {
    packages = [
      nixpkgs-fmt
      lint
    ];
  };
  withUpdater = mkShell {
    inputsFrom = [
      simple
      linyinfeng.updater.env
    ];
    packages = [
      cabal-install
      ormolu
      update
    ];
  };
in

if (linyinfeng ? updater)
then withUpdater
else simple
