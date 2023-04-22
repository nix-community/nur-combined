# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  analitza = pkgs.callPackage ./pkgs/analitza.nix { };
  codeium-vim = pkgs.callPackage ./pkgs/codeium-vim.nix { };
  csharp-ls = pkgs.callPackage ./pkgs/csharp-ls.nix { };
  etherpad = pkgs.callPackage ./pkgs/etherpad.nix { };
  figma = pkgs.callPackage ./pkgs/figma.nix { };
  git-conflict-nvim = pkgs.callPackage ./pkgs/git-conflict-nvim.nix { };
  hybridbar = pkgs.callPackage ./pkgs/hybridbar.nix { };
  kalgebra = pkgs.callPackage ./pkgs/kalgebra.nix { inherit analitza; };
  monocraft = pkgs.callPackage ./pkgs/monocraft.nix { };
  nerdfonts-glyphs = pkgs.callPackage ./pkgs/nerdfonts-glyphs.nix { };
  nvim-scrollbar = pkgs.callPackage ./pkgs/nvim-scrollbar.nix { };
  octicons = pkgs.callPackage ./pkgs/octicons.nix { };
  picom-next = pkgs.callPackage ./pkgs/picom-next.nix { };
  run-keepass = pkgs.callPackage ./pkgs/run-keepass.nix { };
  sfs-select = pkgs.callPackage ./pkgs/sfs-select.nix { };
  show = pkgs.callPackage ./pkgs/show.nix { };
  /* tcount = pkgs.callPackage ./pkgs/tcount.nix { }; */
  tomlplusplus = pkgs.callPackage ./pkgs/tomlplusplus.nix { };
  vim-ctrlspace = pkgs.callPackage ./pkgs/vim-ctrlspace.nix { };
  waycorner = pkgs.callPackage ./pkgs/waycorner.nix { };
  wiki-vim = pkgs.callPackage ./pkgs/wiki-vim.nix { };
}
