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

  # For some reason NUR needs to be passed git-credential-manager explicitly to support self-referencing in passthru.tests
  git-credential-manager = pkgs.callPackage ./pkgs/git-credential-manager { git-credential-manager = git-credential-manager; };
  kuro = pkgs.callPackage ./pkgs/kuro { };
  code-hotfix = pkgs.callPackage ./pkgs/codefix { };

  jetbrains = (pkgs.lib.recurseIntoAttrs
    (pkgs.callPackages pkgs/jetbrains {
      vmopts = pkgs.config.jetbrains.vmopts or null;
      jdk = jetbrains.jdk;
    }) // {
    jdk = pkgs.jetbrains.jdk;
  });
}
