{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs {}
  }:
let
  lib = import ./lib { inherit pkgs; }; # functions

  bcachefs-tools = pkgs.callPackage ./pkgs/bcachefs-tools { };
  bcachefs-master = pkgs.callPackage ./pkgs/bcachefs-kernel {
    kernel = pkgs.linuxKernel.kernels.linux_6_0;
    version = "kent-master";
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
  bcachefs-yo-testing = pkgs.callPackage ./pkgs/bcachefs-kernel {
    kernel = pkgs.linuxKernel.kernels.linux_6_0;
    version = "yo-testing";
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
      { name = "yo-bcachefs-testing.patch";
        patch = ./pkgs/bcachefs-kernel/yo.patch; }
    ];
  };
  overlay = (super: final: { inherit bcachefs-tools bcachefs-master bcachefs-yo-testing; });
in
{
  inherit bcachefs-tools bcachefs-master bcachefs-yo-testing lib;
  # The `lib`, `modules`, and `overlay` names are special
  modules = import ./modules; # NixOS modules
  overlays = [overlay]; # nixpkgs overlays
  bcachefs-iso = (import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      modules = [
        ({...}: {
          nixpkgs.overlays = [ overlay ];
        })
        (
          ./iso.nix
        )
      ];
  }).config.system.build.isoImage;
}
