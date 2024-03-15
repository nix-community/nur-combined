{pkgs ? import <nixpkgs> {}}: {
  lib = import ./lib {inherit pkgs;};
  modules = import ./modules;
  overlays = import ./overlays;

  sketch = pkgs.callPackage ./pkgs/sketch {
    stdenv = let
      inherit (pkgs) stdenv overrideSDK;
    in
      if stdenv.isDarwin
      then overrideSDK stdenv "11.0"
      else stdenv;
  };
  reduce-algebra = pkgs.callPackage ./pkgs/reduce-algebra {};
}
