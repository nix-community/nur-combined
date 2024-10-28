{pkgs ? import <nixpkgs> {}}: let
  darwinStdenv = let
    inherit (pkgs) stdenv overrideSDK;
  in
    if stdenv.isDarwin
    then overrideSDK stdenv "11.0"
    else stdenv;
in {
  lib = import ./lib {inherit pkgs;};
  modules = import ./modules;
  overlays = import ./overlays;

  sketch = pkgs.callPackage ./pkgs/sketch {stdenv = darwinStdenv;};
  reduce-algebra = pkgs.callPackage ./pkgs/reduce-algebra {stdenv = darwinStdenv;};
}
