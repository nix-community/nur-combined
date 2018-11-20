{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {} }:

pkgs.callPackages ./non-broken.nix {}
