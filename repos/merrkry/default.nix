{
  pkgs ? import <nixpkgs> { },
}:
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # Top-level packages must evaluate without import from derivation (IFD).
  # Packages requiring IFD belong in impure.
  impure = {
    determinate-nix = pkgs.callPackage ./pkgs/determinate-nix { };
  };

  bookerly = pkgs.callPackage ./pkgs/bookerly.nix { };
  chatgpt = pkgs.callPackage ./pkgs/chatgpt { };
  codex-bin = pkgs.callPackage ./pkgs/codex-bin { };
  delta = pkgs.callPackage ./pkgs/delta.nix { };
  fcitx5-vinput-lite = pkgs.callPackage ./pkgs/fcitx5-vinput-lite { };
  kache = pkgs.callPackage ./pkgs/kache.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
  symseek = pkgs.callPackage ./pkgs/symseek.nix { };
  t3code-bin = pkgs.callPackage ./pkgs/t3code-bin { channel = "stable"; };
  t3code-nightly-bin = t3code-bin.override { channel = "nightly"; };
  yaasm = pkgs.callPackage ./pkgs/yaasm.nix { };
}
