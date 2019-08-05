let
  config = { allowUnfree = true; doCheckByDefault = false; checkMetaRecursively = true; };
  overlays = let
    mozilla = builtins.tryEval (import <mozilla/rust-overlay.nix>);
  in if mozilla.success then [mozilla.value] else [];
  pkgss = [
    (import <nixpkgs> {
      inherit config overlays;
    })
    (import <nixpkgs> {
      inherit config;
      overlays = overlays ++ [(import ../overlay.nix)];
    })
  ];
  test = pkgs: let
    arc = import ../default.nix { inherit pkgs; };
  in {
    packages = import ./packages.nix { inherit arc; };
    shells = import ./shells.nix {
      inherit arc;
    };
    tests = import ./tests.nix {
      inherit arc;
    };
  };
  module = import ./modules.nix;
  tests' = map test pkgss;
  lib = (import <nixpkgs> {}).lib;
  tests = lib.foldAttrs lib.concat [] tests';
  modules = map module pkgss;
in {
  inherit (tests) packages tests shells;
  inherit modules;
}
