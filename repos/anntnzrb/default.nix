# Having pkgs default to <nixpkgs> allows:
# nix-build -A my-pkg

{ pkgs ? import <nixpkgs> { }
}: {
  # these 3 are especial
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  hihi = pkgs.callPackage ./pkgs/hihi { };
  aider-chat = pkgs.callPackage ./pkgs/aider-chat { };
}
