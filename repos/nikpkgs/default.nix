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
  amdgpud           = pkgs.callPackage ./pkgs/amdgpud { };
  amdgpu-clocks     = pkgs.callPackage ./pkgs/amdgpu-clocks { };
  imhex-bin         = pkgs.callPackage ./pkgs/imhex/appimage.nix { };
  inotify-consumers = pkgs.callPackage ./pkgs/inotify-consumers {};
  lilipod           = pkgs.callPackage ./pkgs/lilipod { };
  memtest-vulkan    = pkgs.callPackage ./pkgs/memtest-vulkan { };
  ntfs2btrfs        = pkgs.callPackage ./pkgs/ntfs2btrfs { };
  obsidian-bin      = pkgs.callPackage ./pkgs/obsidian/appimage.nix { };
  plank-themes      = pkgs.callPackage ./pkgs/plank-themes { };
  qemu-3dfx         = pkgs.callPackage ./pkgs/qemu-3dfx { };
  rustdesk-bin      = pkgs.callPackage ./pkgs/rustdesk/appimage.nix { };
  simulide          = pkgs.callPackage ./pkgs/simulide { };
  tailscale-systray = pkgs.callPackage ./pkgs/tailscale-systray { };
  unison-gitignore  = pkgs.callPackage ./pkgs/unison-gitignore { };
}
