# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Alphabetical sorting
  amdgpu-clocks          = pkgs.callPackage ./pkgs/amdgpu-clocks { };
  avahi2dns              = pkgs.callPackage ./pkgs/avahi2dns { };
  cockpit-podman         = pkgs.callPackage ./pkgs/cockpit-podman { };
  inotify-consumers      = pkgs.callPackage ./pkgs/inotify-consumers { };
  libva-v4l2-request     = pkgs.callPackage ./pkgs/libva-v4l2-request { };
  netsed-quiet           = pkgs.callPackage ./pkgs/netsed { };
  overlayfs-tools        = pkgs.callPackage ./pkgs/overlayfs-tools { };
  plank-themes           = pkgs.callPackage ./pkgs/plank-themes { };
  pw_wp_bluetooth_rpi_speaker =
    pkgs.callPackage ./pkgs/pw_wp_bluetooth_rpi_speaker { };
  qemu-3dfx              = pkgs.callPackage ./pkgs/qemu-3dfx { };
}
