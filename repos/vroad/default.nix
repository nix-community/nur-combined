{ pkgs ? import (import ./nix/sources.nix { }).nixpkgs { } }:
let
  qemu = with pkgs; callPackage ./pkgs/applications/virtualization/qemu {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
    inherit (darwin.stubs) rez setfile;
    inherit (darwin) sigtool;
  };
in
{
  modules = import ./modules; # NixOS modules

  qemu_kvm = pkgs.lowPrio (qemu.override { hostCpuOnly = true; });
}
