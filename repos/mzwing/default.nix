# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  sources = pkgs.callPackage ./_sources/generated.nix {};
  typenix = pkgs.callPackage ./pkgs/typenix {
    source = sources.typenix;
    tree-sitter-nix = sources.tree-sitter-nix;
  };
  typenix-vscode = pkgs.callPackage ./pkgs/typenix-vscode {
    source = sources.typenix;
    inherit typenix;
  };
in {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  homeModules = import ./home-modules; # Home Manager modules
  darwinModules = import ./darwin-modules; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  ace-ctx = pkgs.callPackage ./pkgs/ace-ctx {source = sources.ace-ctx;};
  autocli = pkgs.callPackage ./pkgs/autocli {source = sources.autocli;};
  cliproxyapiplus = pkgs.callPackage ./pkgs/cliproxyapiplus {source = sources.cliproxyapiplus;};
  gryph = pkgs.callPackage ./pkgs/gryph {source = sources.gryph;};
  pumpkin = pkgs.callPackage ./pkgs/pumpkin {source = sources.pumpkin;};
  sing-box-alpha = pkgs.callPackage ./pkgs/sing-box-alpha {source = sources.sing-box-alpha;};
  sing-box-beta = pkgs.callPackage ./pkgs/sing-box-beta {source = sources.sing-box-beta;};
  inherit typenix typenix-vscode;
  vscode-extensions = pkgs.lib.recurseIntoAttrs {
    ryanrasti = pkgs.lib.recurseIntoAttrs {
      typenix = pkgs.callPackage ./pkgs/vscode-extensions/ryanrasti/typenix {
        inherit typenix-vscode;
      };
    };
  };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
