{ pkgs ? import (import ./nix/sources.nix).nixpkgs-unstable { } }:
let
  qemu = with pkgs; callPackage ./pkgs/applications/virtualization/qemu {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
    inherit (darwin.stubs) rez setfile;
    python = python3;
  };
in
{
  modules = import ./modules; # NixOS modules

  qemu = qemu.overrideAttrs (x: {
    preferLocalBuild = true;
  });
  qemu_kvm = pkgs.lowPrio (qemu.override { hostCpuOnly = true; });

  looking-glass-client = pkgs.callPackage ./pkgs/development/virtualization/looking-glass-client { };
}
