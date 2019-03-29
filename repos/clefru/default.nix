{ pkgs ? import <nixpkgs> {} }:
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
 
  # Test a single package:
  # $ nix-build -E '(import <nixpkgs> { overlays = [ (import /home/clemens/devel/nixover-clefru/overlay.nix) ]; }).singlePkgs'
  #
  # Test all packages:
  # $ nix-build -E '((import ./overlay.nix) {} (import <nixpkgs> {}))'
  beam-wallet = pkgs.callPackage ./pkgs/beam {};
  grin = pkgs.callPackage ./pkgs/grin/grin.nix {};
  grin-miner = pkgs.callPackage ./pkgs/grin/grin-miner.nix {};
  linux-sgx = pkgs.callPackage ./pkgs/linux-sgx {};
  rnnoise = pkgs.callPackage ./pkgs/rnnoise {};
  noise-suppression-for-voice = pkgs.callPackage ./pkgs/noise-suppression-for-voice {};
  scanbuttond = pkgs.callPackage ./pkgs/scanbuttond {};
  minionpro = pkgs.callPackage ./pkgs/minionpro {};
  omnicore = pkgs.callPackage ./pkgs/omnicore { withGui = true; };
#  python-pure25519 = pkgs.callPackage ./pkgs/python-pure25519 { buildPythonPackage = pkgs.python27.buildPythonPackage } };
}
