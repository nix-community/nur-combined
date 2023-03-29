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

  copyq = pkgs.callPackage ./pkgs/copyq { };
  dssp = pkgs.callPackage ./pkgs/dssp { };
  doq = pkgs.python3Packages.callPackage ./pkgs/doq { };
  ligaturizer = pkgs.callPackage ./pkgs/ligaturizer { };
  mmseqs2 = pkgs.callPackage ./pkgs/mmseqs2 {
    inherit (pkgs.llvmPackages) openmp;
  };
  psipred = pkgs.callPackage ./pkgs/psipred { };
  qutebrowser = pkgs.callPackage ./pkgs/qutebrowser { };
  hackgen = pkgs.callPackage ./pkgs/data/fonts/hackgen { };
  hackgen-nf = pkgs.callPackage ./pkgs/data/fonts/hackgen-nf { };
  liga-hackgen-font = pkgs.callPackage ./pkgs/data/fonts/liga-hackgen { };
  liga-hackgen-nf-font = pkgs.callPackage ./pkgs/data/fonts/liga-hackgen/nerdfont.nix { };

  vimPlugins = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/vim-plugins { inherit (pkgs.vimUtils) buildVimPlugin; });
}
