{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {} }:

import ./non-broken.nix { inherit pkgs; }
