{ pkgs ? import <nixpkgs> {} } :

{
  overlays = {
    NixOS-QChem = import ./default.nix;
  };
}

