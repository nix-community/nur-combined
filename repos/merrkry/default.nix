{
  pkgs ? import <nixpkgs> { },
}:
let
  packages = rec {
    codex-bin = pkgs.callPackage ./pkgs/codex-bin { };
    delta = pkgs.callPackage ./pkgs/delta { };
    deepseek-harness = pkgs.callPackage ./pkgs/deepseek-harness { };
    determinate-nix = pkgs.callPackage ./pkgs/determinate-nix { };
    fcitx5-vinput-lite = pkgs.callPackage ./pkgs/fcitx5-vinput-lite { };
    kache = pkgs.callPackage ./pkgs/kache.nix { };
    kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
    symseek = pkgs.callPackage ./pkgs/symseek.nix { };
    t3code-bin = pkgs.callPackage ./pkgs/t3code-bin { channel = "stable"; };
    t3code-nightly-bin = t3code-bin.override { channel = "nightly"; };
    yaasm = pkgs.callPackage ./pkgs/yaasm.nix { };
  };
in
packages
// {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # Top-level packages must evaluate without import from derivation (IFD).
  # Packages requiring IFD belong in impure.
  impure = { };

  # Keep packaging sources out of the NUR package index; build-jobs enables recursion.
  repo-sources = pkgs.lib.mapAttrs (_: package: package.packagingSource) (
    pkgs.lib.filterAttrs (_: package: package ? packagingSource) packages
  );
}
