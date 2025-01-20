# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { overlays = builtins.attrValues (import ./overlays); },
}:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bclm = pkgs.callPackage ./pkgs/bclm { };
  copyq = pkgs.copyq;
  emacs-plus = pkgs.callPackage ./pkgs/emacs-plus { source = sources.emacs-plus; };
  emacs29-plus = pkgs.callPackage ./pkgs/emacs-plus {
    source = sources.emacs-plus;
    emacs = pkgs.emacs29;
  };
  emacs30-plus = pkgs.callPackage ./pkgs/emacs-plus {
    source = sources.emacs-plus;
    emacs = pkgs.emacs30;
  };
  ligaturizer = pkgs.callPackage ./pkgs/ligaturizer { };
  nixpkgs-review = pkgs.nixpkgs-review;
  psipred = pkgs.callPackage ./pkgs/psipred { };
  qmk-toolbox = pkgs.callPackage ./pkgs/qmk-toolbox { source = sources.qmk-toolbox; };
  qutebrowser = pkgs.qutebrowser;
  rofi-rbw = pkgs.rofi-rbw;
  sbarlua = pkgs.callPackage ./pkgs/sbarlua { source = sources.sbarlua; };
  vivaldi = pkgs.vivaldi;
  zen-browser = pkgs.callPackage ./pkgs/zen-browser { source = sources.zen-browser; };
  liga-hackgen-font = pkgs.callPackage ./pkgs/data/fonts/liga-hackgen { inherit ligaturizer; };
  liga-hackgen-nf-font = liga-hackgen-font.override { nerdfont = true; };

  vimPlugins = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/vim-plugins {
      inherit (pkgs.vimUtils) buildVimPlugin;
      inherit sources;
    }
  );
}
