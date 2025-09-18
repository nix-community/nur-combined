# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  catppuccin-obsidian = pkgs.callPackage ./pkgs/catppuccin-obsidian {};
  cmdr = pkgs.callPackage ./pkgs/cmdr {};
  folder-notes = pkgs.callPackage ./pkgs/folder-notes {};
  hayase = pkgs.callPackage ./pkgs/hayase {};
  helium = pkgs.callPackage ./pkgs/helium {};
  hyprshot = pkgs.callPackage ./pkgs/hyprshot {};
  obsidian-excalidraw-plugin = pkgs.callPackage ./pkgs/obsidian-excalidraw-plugin {};
  obsidian-git = pkgs.callPackage ./pkgs/obsidian-git {};
  obsidian-hider = pkgs.callPackage ./pkgs/obsidian-hider {};
  obsidian-relative-line-numbers = pkgs.callPackage ./pkgs/obsidian-relative-line-numbers {};
  obsidian-scroll-offset = pkgs.callPackage ./pkgs/obsidian-scroll-offset {};
  obsidian-style-settings = pkgs.callPackage ./pkgs/obsidian-style-settings {};
  obsidian-vim-yank-highlight = pkgs.callPackage ./pkgs/obsidian-vim-yank-highlight {};
  obsidian-vimrc-support = pkgs.callPackage ./pkgs/obsidian-vimrc-support {};
}
