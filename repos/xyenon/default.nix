# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
let
  sources = import ./_sources/generated.nix {
    inherit
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };
in
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  hmModules = import ./hm-modules; # Home Manager modules
  overlays = import ./overlays; # nixpkgs overlays

  go-check = callPackage ./pkgs/go-check { };
  catp = callPackage ./pkgs/catp { };
  vodozemac-bindings-kazv-unstable = callPackage ./pkgs/vodozemac-bindings-kazv { };
  libkazv = callPackage ./pkgs/libkazv {
    inherit vodozemac-bindings-kazv-unstable;
    libcpr = pkgs.libcpr_1_10_5 or libcpr;
  };
  kazv = kdePackages.callPackage ./pkgs/kazv { inherit vodozemac-bindings-kazv-unstable libkazv; };
  nginxModules = callPackage ./pkgs/nginx/modules { };
  nginxStable =
    let
      nginxStable' = pkgs.nginxStable;
    in
    nginxStable'.override {
      modules =
        nginxStable'.modules ++ (with nginxModules; [ (http_proxy_connect nginxStable'.version) ]);
    };
  nginxMainline =
    let
      nginxMainline' = pkgs.nginxMainline;
    in
    nginxMainline'.override {
      modules =
        nginxMainline'.modules ++ (with nginxModules; [ (http_proxy_connect nginxMainline'.version) ]);
    };
  nginx = nginxStable;
  mpvScripts = callPackage ./pkgs/mpv/scripts { };
  anime4k = callPackage ./pkgs/anime4k { };
  yaziPlugins = callPackage ./pkgs/yazi/plugins { inherit sources; };
  telemikiya = callPackage ./pkgs/telemikiya { };
  librime-qjs = callPackage ./pkgs/librime-qjs { };
  librime = pkgs.librime.override {
    plugins = [
      librime-qjs
      librime-lua
      librime-octagram
    ];
  };
  rime-moegirl = callPackage ./pkgs/rime-moegirl { source = sources.rime-moegirl; };
  rime-ice = callPackage ./pkgs/rime-ice { inherit sources; };
  rime-ice-unstable = rime-ice.override { isUnstable = true; };
  caddy = callPackage ./pkgs/caddy { inherit sources; };
  pleroma = callPackage ./pkgs/pleroma {
    beamPackages = beam27Packages.extend (
      self: _super: { rebar3 = self.rebar3WithPlugins { plugins = with self; [ pc ]; }; }
    );
  };
  oli = callPackage ./pkgs/oli { };
  catppuccin = callPackage ./pkgs/catppuccin { inherit sources; };
}
