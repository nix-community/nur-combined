{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bcachefs-tools = pkgs.callPackage ./pkgs/bcachefs-tools { };
  bcachefs-kernel = pkgs.callPackage ./pkgs/bcachefs-kernel {
    kernel = pkgs.linuxKernel.kernels.linux_5_19;
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
}
