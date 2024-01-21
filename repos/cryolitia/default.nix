# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

builtins.trace "「我书写，则为我命令。我陈述，则为我规定。」"

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  #example-package = pkgs.callPackage ./pkgs/example-package { };

  MaaAssistantArknights = pkgs.callPackage ./pkgs/MaaAssistantArknights { };

  MaaAssistantArknights-cuda = MaaAssistantArknights.override {
    cudaSupport = true;
  };

  MaaAssistantArknights-cuda-bin = MaaAssistantArknights-cuda.override {
    onnxruntime-cuda = onnxruntime-cuda-bin;
  };

  MaaAssistantArknights-beta = MaaAssistantArknights.override {
    #maaVersion = "4.28.0";
    #maaSourceHash = "sha256-SKPKFD70wwmBXqolh8eLmHbL1ckDORiAH+LFBjC+o1A=";
  };

  MaaAssistantArknights-beta-cuda = MaaAssistantArknights-beta.override {
    cudaSupport = true;
  };

  MaaAssistantArknights-beta-cuda-bin = MaaAssistantArknights-beta-cuda.override {
    onnxruntime-cuda = onnxruntime-cuda-bin;
  };

  # fastdeploy_ppocr = pkgs.callPackage ./pkgs/MaaAssistantArknights/fastdeploy_ppocr.nix { };

  MaaX = pkgs.callPackage ./pkgs/MaaX { };

  onnxruntime-cuda = pkgs.callPackage ./pkgs/MaaAssistantArknights/onnxruntime-cuda.nix { };

  onnxruntime-cuda-bin = pkgs.callPackage ./pkgs/MaaAssistantArknights/onnxruntime-cuda-bin.nix { };

  maa-cli = pkgs.callPackage ./pkgs/MaaAssistantArknights/maa-cli.nix { };

  rime-latex = pkgs.callPackage ./pkgs/rimePackages/rime-latex.nix { };

  go-musicfox-fastupdate = pkgs.callPackage ./pkgs/common/go-musicfox.nix { };

  rime-project-trans = pkgs.callPackage ./pkgs/rimePackages/rime-project-trans.nix { };

  cmd-wrapped = pkgs.callPackage ./pkgs/common/cmd-wrapped.nix { };

  #ryzen-smu = pkgs.linuxPackages.callPackage ./pkgs/linux/ryzen-smu.nix { };

  bmi260 = pkgs.linuxPackages_latest.callPackage ./pkgs/linux/bmi260.nix { };
}
