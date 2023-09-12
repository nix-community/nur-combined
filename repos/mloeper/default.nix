# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  modules = import ./modules;

  # For some reason NUR needs to be passed git-credential-manager explicitly to support self-referencing in passthru.tests
  git-credential-manager = pkgs.callPackage ./pkgs/git-credential-manager { git-credential-manager = git-credential-manager; };
  usbguard-applet-qt = pkgs.callPackage ./pkgs/usbguard-applet-qt { };
  dashlane-cli = pkgs.callPackage ./pkgs/dashlane-cli { };
  devcontainer-cli-unofficial = pkgs.callPackage ./pkgs/devcontainer-cli-unofficial { };
  glib = pkgs.callPackage ./pkgs/glib { };
  mingo = pkgs.callPackage ./pkgs/mingo { };
}
