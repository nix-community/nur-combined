# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  cockpit = pkgs.callPackage ./pkgs/cockpit {};
  cockpit-machines = pkgs.callPackage ./pkgs/cockpit/machines.nix {};
  #cockpit-client = cockpit.override { client = true; };
  libvirt-dbus = pkgs.callPackage ./pkgs/libvirt-dbus {};
  cockpit-podman = pkgs.callPackage ./pkgs/cockpit/podman.nix { };
  linux_sbos = pkgs.callPackage ./pkgs/linux {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
  searxng = pkgs.callPackage ./pkgs/searxng { };
}
