{ pkgs ? import <nixpkgs> {} }:
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  beam-wallet = pkgs.callPackage ./pkgs/beam {};
  grin = pkgs.callPackage ./pkgs/grin/grin.nix {};
  grin-miner = pkgs.callPackage ./pkgs/grin/grin-miner.nix {};
  linux-sgx = pkgs.callPackage ./pkgs/linux-sgx {};
  rnnoise = pkgs.callPackage ./pkgs/rnnoise {};
  noise-suppression-for-voice = pkgs.callPackage ./pkgs/noise-suppression-for-voice {};
  scanbuttond = pkgs.callPackage ./pkgs/scanbuttond {};
  minionpro = pkgs.callPackage ./pkgs/minionpro {};
#  python-pure25519 = pkgs.callPackage ./pkgs/python-pure25519 { buildPythonPackage = pkgs.python27.buildPythonPackage } };
}
