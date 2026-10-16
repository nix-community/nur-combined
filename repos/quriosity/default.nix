{ pkgs ? import <nixpkgs> { } }:

{
  # Modules/Overlays
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  homeModules = import ./home-modules; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  # Apps
  BedrockNix = pkgs.callPackage ./pkgs/apps/BedrockNix {};
  olauncher = pkgs.callPackage ./pkgs/apps/olauncher {};
  leshade = pkgs.callPackage ./pkgs/apps/leshade {};
  zen-browser = pkgs.callPackage ./pkgs/apps/zen-browser {};
  zen-twilight = pkgs.callPackage ./pkgs/apps/zen-browser/twilight.nix {};
  tabby = pkgs.callPackage ./pkgs/apps/tabby {};
  hyper = pkgs.callPackage ./pkgs/apps/hyper {};
  opennow = pkgs.callPackage ./pkgs/apps/opennow {};
  openide = pkgs.callPackage ./pkgs/apps/openide {};
  # Artcraft Suite
  artcraft-launcher = pkgs.callPackage ./pkgs/apps/artcraft-suite/artcraft-launcher {};
  photocraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/photocraft {};
  filmcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/filmcraft {};
  effectcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/effectcraft {};
  designcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/designcraft {};
  pdfcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/pdfcraft {};
  lightcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/lightcraft {};
  vectorcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/vectorcraft {};
  wordcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/wordcraft {};
  deckcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/deckcraft {};
  gridcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/gridcraft {};
  soundcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/soundcraft {};
  cadcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/cadcraft {};
  figcraft = pkgs.callPackage ./pkgs/apps/artcraft-suite/figcraft {};

  # Compatibility tools
  proton-ge = pkgs.callPackage ./pkgs/compat-tools/ge-proton {};
  dwproton = pkgs.callPackage ./pkgs/compat-tools/dwproton {};
  proton-wineland = pkgs.callPackage ./pkgs/compat-tools/proton-wineland {};
  proton-wineland-v3 = pkgs.callPackage ./pkgs/compat-tools/proton-wineland { variant = "x86_64-v3"; };
  proton-cachyos = pkgs.callPackage ./pkgs/compat-tools/proton-cachyos {};
  proton-cachyos-v3 = pkgs.callPackage ./pkgs/compat-tools/proton-cachyos { variant = "x86_64-v3"; };

  # SDDM themes
  echo-sddm = pkgs.callPackage ./pkgs/sddm-themes/echo-sddm {};
  where-is-my-sddm-theme = pkgs.callPackage ./pkgs/sddm-themes/where-is-my-sddm-theme {};

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
