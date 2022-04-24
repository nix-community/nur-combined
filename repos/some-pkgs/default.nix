# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

let
  impureNixpkgs' = import <nixpkgs> { };
  impureNixpkgs = builtins.trace "ACHTUNG! Impure import <nixpkgs>" impureNixpkgs';
in
{ pkgs ? impureNixpkgs }:

let
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  self = {
    # The `lib`, `modules`, and `overlay` names are special
    inherit lib modules overlays;
    inherit (pkgs) config;

    accelerate = pkgs.python3Packages.callPackage ./pkgs/accelerate.nix { inherit (self) lib accelerate; };

    pyimgui = pkgs.python3Packages.callPackage ./pkgs/pyimgui {
      inherit lib;
      inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
    };
    dearpygui = pkgs.python3Packages.callPackage ./pkgs/dearpygui {
      inherit lib;
      inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
    };

    opensfm = pkgs.python3Packages.callPackage ./pkgs/opensfm { inherit lib; };
    kornia = pkgs.python3Packages.callPackage ./pkgs/kornia.nix { inherit (self) lib accelerate kornia; };
    gpytorch = pkgs.python3Packages.callPackage ./pkgs/gpytorch.nix { inherit lib; };

    instant-ngp = pkgs.python3Packages.callPackage ./pkgs/instant-ngp
      ({
        inherit lib;
        cudnn = pkgs.cudnn_8_3_cudatoolkit_11_4 or pkgs.cudnn_cudatoolkit_11_4;
      }
      // lib.optionalAttrs (pkgs.python3Packages ? lark-parser) {
        lark = pkgs.python3Packages.lark-parser;
      });

    tensorflow-probability_8_0 = pkgs.python3Packages.callPackage ./pkgs/tfp/8.0.nix { inherit (self) lib; };
  }
  // pkgs.lib.optionalAttrs (pkgs.lib.versionAtLeast pkgs.lib.version "22.05pre") {
    gpflow = pkgs.python3Packages.callPackage ./pkgs/gpflow.nix { inherit (self) lib tensorflow-probability_8_0; };
    gpflux = pkgs.python3Packages.callPackage ./pkgs/gpflux.nix { inherit (self) lib gpflow tensorflow-probability_8_0; };
    trieste = pkgs.python3Packages.callPackage ./pkgs/trieste.nix { inherit (self) lib gpflow gpflux tensorflow-probability_8_0; };
  };
in
self
