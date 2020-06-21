# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hassLovelaceModules = pkgs.recurseIntoAttrs {
    mini-graph-card = (pkgs.callPackage ./pkgs/home-assistant/lovelaceModules/mini-graph-card {});
    mini-media-player = (pkgs.callPackage ./pkgs/home-assistant/lovelaceModules/mini-media-player {});
    multiple-entity-row = (pkgs.callPackage ./pkgs/home-assistant/lovelaceModules/multiple-entity-row {});
    rmv-card = (pkgs.callPackage ./pkgs/home-assistant/lovelaceModules/rmv-card {});
  };

  hassThemes = pkgs.recurseIntoAttrs {
    clear = (pkgs.callPackage ./pkgs/home-assistant/themes/clear {});
    clear-dark = (pkgs.callPackage ./pkgs/home-assistant/themes/clear-dark {});
  };

  oscam = pkgs.callPackage ./pkgs/servers/tv/oscam { };

  trinitycore_335 = (pkgs.callPackage ./pkgs/servers/games/trinitycore { });
  trinitycore_825 = (pkgs.callPackage ./pkgs/servers/games/trinitycore/825.nix { });
}

