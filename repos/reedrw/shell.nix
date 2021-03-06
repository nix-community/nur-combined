with import <nixpkgs> { };
let
  sources = import ./nix/sources.nix;

  devshell = import "${sources.devshell}/overlay.nix";

  pkgs = import <nixpkgs> {
    inherit system;
    overlays = [
      devshell
    ];
  };


in
pkgs.mkDevShell.fromTOML ./devshell.toml
