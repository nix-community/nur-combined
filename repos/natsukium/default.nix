# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
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
  colima = pkgs.callPackage ./pkgs/colima { };
  copyq = pkgs.callPackage ./pkgs/copyq { source = sources.copyq-darwin; };
  emacs-plus = pkgs.callPackage ./pkgs/emacs-plus { source = sources.emacs-plus; };
  ligaturizer = pkgs.callPackage ./pkgs/ligaturizer { };
  nixfmt = pkgs.callPackage ./pkgs/nixfmt { source = sources.nixfmt; };
  nixpkgs-review = pkgs.callPackage ./pkgs/nixpkgs-review { source = sources.nixpkgs-review; };
  nowplaying-cli = pkgs.callPackage ./pkgs/nowplaying-cli {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
    source = sources.nowplaying-cli;
  };
  psipred = pkgs.callPackage ./pkgs/psipred { };
  qmk-toolbox = pkgs.callPackage ./pkgs/qmk-toolbox { source = sources.qmk-toolbox; };
  qutebrowser = pkgs.callPackage ./pkgs/qutebrowser { source = sources.qutebrowser-darwin; };
  rofi-rbw = pkgs.callPackage ./pkgs/rofi-rbw { };
  sbarlua = pkgs.callPackage ./pkgs/sbarlua { source = sources.sbarlua; };
  vim-startuptime = pkgs.callPackage ./pkgs/vim-startuptime { source = sources.vim-startuptime; };
  vivaldi-bin = pkgs.callPackage ./pkgs/vivaldi { source = sources.vivaldi-darwin; };
  liga-hackgen-font = pkgs.callPackage ./pkgs/data/fonts/liga-hackgen { inherit ligaturizer; };
  liga-hackgen-nf-font = liga-hackgen-font.override { nerdfont = true; };

  vimPlugins = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/vim-plugins {
      inherit (pkgs.vimUtils) buildVimPlugin;
      inherit sources;
    }
  );
}
