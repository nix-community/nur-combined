{ mkShell, lib, linyinfeng, lint, update, nixpkgs-fmt, cabal-install, ormolu }:

let
  notBroken = p: !(p.meta.broken or false);
  guard = p: lib.optional (notBroken p) p;
  simple = mkShell {
    packages =
      [ nixpkgs-fmt ] ++
      guard lint;
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
