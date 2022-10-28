{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs {}
  }:
let
  lib = import ./lib { inherit pkgs; }; # functions

  bcachefs-tools = pkgs.callPackage ./pkgs/bcachefs-tools { };
  bcachefs-kernel = pkgs.callPackage ./pkgs/bcachefs-kernel {
    kernel = pkgs.linuxKernel.kernels.linux_5_19;
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
in
{
  inherit bcachefs-tools bcachefs-kernel lib;
  # The `lib`, `modules`, and `overlay` names are special
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  bcachefs-iso = (import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      modules = [
        ({...}: {
          nixpkgs.overlays = [(super: final: { inherit bcachefs-tools bcachefs-kernel;})];
        })
        (
          ./iso.nix
        )
      ];
  }).config.system.build.isoImage;
}
