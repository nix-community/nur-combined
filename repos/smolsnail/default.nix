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

  # Programs
  bandcamp-dl = pkgs.python39Packages.callPackage ./pkgs/bandcamp-dl { };
  arduino-language-server = pkgs.callPackage ./pkgs/arduino-language-server { };
  neocities-ruby = pkgs.callPackage ./pkgs/neocities-ruby { };
  pat = pkgs.python39Packages.callPackage ./pkgs/pat { };
  speedtime = pkgs.callPackage ./pkgs/speedtime { };

  # Themes/cursors/icons
  cursor-left-yaru = pkgs.callPackage ./pkgs/cursor-left-yaru { };
  everforest-gtk = pkgs.callPackage ./pkgs/everforest-gtk { };
  monochrome-kde = pkgs.callPackage ./pkgs/monochrome-kde { };

  # Vim color schemes
  everforest = pkgs.callPackage ./pkgs/everforest {
    buildVimPlugin = pkgs.vimUtils.buildVimPlugin;
  };
  rose-pine-neovim = pkgs.callPackage ./pkgs/rose-pine-neovim {
    buildVimPlugin = pkgs.vimUtils.buildVimPlugin;
  };

  # Package groups
  firefox-addons =
    pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });
  nodePackages =
    pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/nodePackages { });
}
