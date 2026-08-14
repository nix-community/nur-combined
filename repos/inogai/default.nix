# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  customLib = import ./lib {inherit pkgs;};
  lib = pkgs.lib // customLib;
  callPackage = lib.callPackageWith (pkgs // {inherit lib;});
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = customLib; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  fzfmenu = callPackage ./pkgs/fzfmenu {};
  moegi-nvim = callPackage ./pkgs/moegi-nvim {};
  prequery-preprocess = callPackage ./pkgs/prequery-preprocess {};
  prettier-inogai = callPackage ./pkgs/prettier-inogai {};
  pi-web-agegr = callPackage ./pkgs/pi-web-agegr {};
  pi-web-jmfederico = callPackage ./pkgs/pi-web-jmfederico {};
  # Deprecated: the original `pi-web` attr (was the jmfederico package). Both
  # projects are literally named "pi-web" (agegr/pi-web, jmfederico/pi-web),
  # so use the explicit names: pi-web-agegr or pi-web-jmfederico.
  pi-web = lib.warn "pi-web is deprecated — use pi-web-agegr or pi-web-jmfederico" (
    callPackage ./pkgs/pi-web-jmfederico {}
  );
  ray-raycast = callPackage ./pkgs/ray-raycast {};
  winterm-rs = callPackage ./pkgs/winterm-rs {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
