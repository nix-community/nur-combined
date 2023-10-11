# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  maintainers = import ./maintainers.nix;

  #example-package = pkgs.callPackage ./pkgs/example-package { };
  
  MaaAssistantArknights = pkgs.callPackage ./pkgs/MaaAssistantArknights { 
    inherit maintainers;
  };

  MaaAssistantArknights-cuda = MaaAssistantArknights.override { 
    cudaSupport = true;
  };

  MaaAssistantArknights-beta = MaaAssistantArknights.override { 
    maaVersion = "4.25.0";
    maaSourceHash = "sha256-NcfrpLgduemiEJ8jeLY14lZgs67ocZX+7SSIxSC2otk=";
  };

  MaaAssistantArknights-beta-cuda = MaaAssistantArknights-beta.override { 
    cudaSupport = true;
  };

  fastdeploy_ppocr = pkgs.callPackage ./pkgs/MaaAssistantArknights/fastdeploy_ppocr.nix { };

  MaaX = pkgs.callPackage ./pkgs/MaaX { 
    inherit maintainers;
  };

  onnxruntime-cuda = pkgs.callPackage ./pkgs/MaaAssistantArknights/onnxruntime-cuda.nix {  };

}
