# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage


{ pkgs ? null, flake-enabled ? false }:
# The `lib`, `modules`, and `overlay` names are special
let
  # /home/riro/Src/ github:oluceps
  realPkgs = if flake-enabled then pkgs else (import ((builtins.getFlake "github:oluceps/nur-pkgs").inputs.nixpkgs) { system = "x86_64-linux"; });
  lib = realPkgs.lib;
  ifFlake = m: n: if flake-enabled then m else n;
  callPackage = realPkgs.callPackage;
  genPkgs = names: lib.genAttrs names (name: callPackage ./pkgs/${name} { });
  general = genPkgs
    [
      "sing-box"
      "Graphite-cursors"
      "rustplayer"
      # "naiveproxy"
      "techmino"
      "oppo-sans"
      "maoken-tangyuan"
      "plangothic"
      "v2ray-plugin"
      "san-francisco"
      "hk-grotesk"
      "lxgw-neo-xihei"
      "dae"
    ];

  # some packages only avaliable while flake enabled
  flake-specific = ifFlake
    (genPkgs
      [ "shadow-tls" ])
    { };
in
general // flake-specific  

