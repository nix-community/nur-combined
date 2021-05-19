# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs }:

{
  # Evolution.
  beast = pkgs.callPackage ./pkgs/evolution/beast {};
  beast2 = pkgs.callPackage ./pkgs/evolution/beast2 {};
  figtree = pkgs.callPackage ./pkgs/evolution/figtree {};
  iqtree2 = pkgs.callPackage ./pkgs/evolution/iqtree2 {};
  revbayes = pkgs.callPackage ./pkgs/evolution/revbayes {};
  tracer = pkgs.callPackage ./pkgs/evolution/tracer {};

  # Misc.
  biblib = pkgs.callPackage ./pkgs/misc/biblib {};
  frida-python = pkgs.callPackage ./pkgs/misc/frida-python {};
  frida-tools = pkgs.callPackage ./pkgs/misc/frida-tools {
    frida-python = pkgs.callPackage ./pkgs/misc/frida-python {};
  };
  nvd = pkgs.callPackage ./pkgs/misc/nvd {};
  signal-back = pkgs.callPackage ./pkgs/misc/signal-back {};
}
