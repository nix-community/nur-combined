# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  rust-overlay ? false,
}:
builtins.trace "「我书写，则为我命令。我陈述，则为我规定。」" rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules

  # maa-assistant-arknights-nightly = pkgs.callPackage ./pkgs/maa-assistant-arknights { };

  # onnxruntime-cuda-bin = pkgs.callPackage ./pkgs/maa-assistant-arknights/onnxruntime-cuda-bin.nix { };

  # maa-x = pkgs.callPackage ./pkgs/maa-assistant-arknights/maa-x.nix { };

  # maa-cli-nightly = pkgs.callPackage ./pkgs/maa-assistant-arknights/maa-cli.nix {
  #   maa-cli' = pkgs.maa-cli.override { maa-assistant-arknights = maa-assistant-arknights-nightly; };
  # };

  pkgsStatic = {

  };
}
// pkgs.lib.packagesFromDirectoryRecursive {
  callPackage =
    if rust-overlay then
      pkgs.lib.callPackageWith (
        pkgs
        // {
          rustPlatform = pkgs.makeRustPlatform {
            cargo = pkgs.rust-bin.beta.latest.minimal;
            rustc = pkgs.rust-bin.beta.latest.minimal;
          };
        }
      )
    else
      pkgs.callPackage;
  directory = ./pkgs/by-name;
}
