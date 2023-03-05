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
  callPackage = if flake-enabled then pkgs.callPackage else (import <nixpkgs> { }).callPackage;
  genPkgs = names: pkgs.lib.genAttrs names (name: callPackage ./pkgs/${name} { });
  general = genPkgs
    [
      "sing-box"
      "Graphite-cursors"
      "rustplayer"
      "naiveproxy"
      "techmino"
      "oppo-sans"
      "maoken-tangyuan"
      "plangothic"
      "v2ray-plugin"
      "san-francisco"
    ];

  # some packages only avaliable while flake enabled
  flake-specific =
    if flake-enabled then {
      shadow-tls = callPackage ./pkgs/shadow-tls { };
    }
    else { };
in
general // flake-specific
# //
# { modules = import ./modules; }
  

