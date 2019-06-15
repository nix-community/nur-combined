{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {} }:

{
  pkgs-linux = pkgs.callPackages ./non-broken.nix {};
}
