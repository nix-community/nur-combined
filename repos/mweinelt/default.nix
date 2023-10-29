# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs)
    callPackage
    recurseIntoAttrs
  ;
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hassLovelaceModules = recurseIntoAttrs {
    apexcharts-card = callPackage ./pkgs/home-assistant/lovelaceModules/apexcharts-card {};
    atomic-calendar-revive = callPackage ./pkgs/home-assistant/lovelaceModules/atomic-calendar-revive {};
    button-card = callPackage ./pkgs/home-assistant/lovelaceModules/button-card {};
    ha-sankey-chart = callPackage ./pkgs/home-assistant/lovelaceModules/ha-sankey-chart {};
    mini-graph-card = callPackage ./pkgs/home-assistant/lovelaceModules/mini-graph-card {};
    mini-media-player = callPackage ./pkgs/home-assistant/lovelaceModules/mini-media-player {};
    multiple-entity-row = callPackage ./pkgs/home-assistant/lovelaceModules/multiple-entity-row {};
    mushroom = callPackage ./pkgs/home-assistant/lovelaceModules/mushroom {};
    rgb-light-card = callPackage ./pkgs/home-assistant/lovelaceModules/rgb-light-card {};
    rmv-card = callPackage ./pkgs/home-assistant/lovelaceModules/rmv-card {};
    sun-card = callPackage ./pkgs/home-assistant/lovelaceModules/sun-card {};
    slider-button-card = callPackage ./pkgs/home-assistant/lovelaceModules/slider-button-card {};
    swipe-navigation = callPackage ./pkgs/home-assistant/lovelaceModules/swipe-navigation {};
    template-entity-row = callPackage ./pkgs/home-assistant/lovelaceModules/template-entity-row {};
    vacuum-card = callPackage ./pkgs/home-assistant/lovelaceModules/vacuum-card {};
    valetudo-map-card = callPackage ./pkgs/home-assistant/lovelaceModules/valetudo-map-card {};
    weather-card-chart = callPackage ./pkgs/home-assistant/lovelaceModules/weather-card-chart {};
  };

  hassThemes = recurseIntoAttrs {
    clear = callPackage ./pkgs/home-assistant/themes/clear {};
    clear-dark = callPackage ./pkgs/home-assistant/themes/clear-dark {};
  };

  oscam = callPackage ./pkgs/servers/tv/oscam { };

  cmangos_classic = callPackage ./pkgs/servers/games/cmangos/classic.nix { };
  cmangos_tbc = callPackage ./pkgs/servers/games/cmangos/tbc.nix { };
  cmangos_wotlk = callPackage ./pkgs/servers/games/cmangos/wotlk.nix { };

  vmangos = callPackage ./pkgs/servers/games/vmangos {};
  vmangos-worlddb = callPackage ./pkgs/servers/games/vmangos/worlddb.nix {};
}
