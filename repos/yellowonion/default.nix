{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs {}
  }:
let
  lib = import ./lib { inherit pkgs; }; # functions

  mkKernel = name: debug: extraPatches : (pkgs.callPackage ./pkgs/bcachefs-kernel {
    debug = debug;
    kernel = pkgs.linuxKernel.kernels.linux_6_0;
    version = name ;
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ] ++ extraPatches;
  });

  bcachefs-tools = pkgs.callPackage ./pkgs/bcachefs-tools { };
  bcachefs-kernel-kent = mkKernel "kent-master" false [];
  bcachefs-kernel-kent-debug = mkKernel "kent-master" true [];
  bcachefs-kernel-woob = mkKernel "woob-testing" false [
    # { name = "Multi-Gen-LRU-Framework.patch" ;
    #  patch = ./pkgs/bcachefs-kernel/Multi-Gen-LRU-Framework.patch ; }
    { name = "woob-bcachefs-testing.patch";
      patch = ./pkgs/bcachefs-kernel/woob.patch; }
    ];
  bcachefs-kernel-woob-debug = mkKernel "woob-testing" true [
    # { name = "Multi-Gen-LRU-Framework.patch" ;
    #  patch = ./pkgs/bcachefs-kernel/Multi-Gen-LRU-Framework.patch ; }
    { name = "woob-bcachefs-testing.patch";
      patch = ./pkgs/bcachefs-kernel/woob.patch; }
  ];
  overlay = (super: final: { inherit bcachefs-tools bcachefs-kernel-kent bcachefs-kernel-woob; });
in
{
  inherit
    bcachefs-tools
    bcachefs-kernel-kent
    bcachefs-kernel-kent-debug
    bcachefs-kernel-woob
    bcachefs-kernel-woob-debug
    lib;
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
