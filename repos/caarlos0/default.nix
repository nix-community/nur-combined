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

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  clone-org = pkgs.callPackage ./pkgs/clone-org { };
  discord-applemusic-rich-presence = pkgs.callPackage ./pkgs/discord-applemusic-rich-presence { };
  envdoc = pkgs.callPackage ./pkgs/envdoc { };
  fork-cleaner = pkgs.callPackage ./pkgs/fork-cleaner { };
  glyphs = pkgs.callPackage ./pkgs/glyphs { };
  gocovsh = pkgs.callPackage ./pkgs/gocovsh { };
  golangci-lint = pkgs.callPackage ./pkgs/golangci-lint { };
  gopls = pkgs.callPackage ./pkgs/gopls { };
  jsonfmt = pkgs.callPackage ./pkgs/jsonfmt { };
  mdtree = pkgs.callPackage ./pkgs/mdtree { };
  misspell = pkgs.callPackage ./pkgs/misspell { };
  org-stats = pkgs.callPackage ./pkgs/org-stats { };
  svu = pkgs.callPackage ./pkgs/svu { };
  timer = pkgs.callPackage ./pkgs/timer { };
  xdg-open-svc = pkgs.callPackage ./pkgs/xdg-open-svc { };
  diffnav = pkgs.callPackage ./pkgs/diffnav { };

  mkdocs-include-markdown-plugin = pkgs.callPackage ./pkgs/mkdocs-include-markdown-plugin { };
  mkdocs-git-revision-date-localized-plugin =
    pkgs.callPackage ./pkgs/mkdocs-git-revision-date-localized-plugin
      { };
}
