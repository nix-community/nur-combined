{ pkgs ? import <nixpkgs> { } }: {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
  swiftBuilders = pkgs.callPackage ./pkgs/swift-builders { };
  TOMLDecoder = pkgs.callPackage ./pkgs/TOMLDecoder { };
  Yams = pkgs.callPackage ./pkgs/Yams { };
}
