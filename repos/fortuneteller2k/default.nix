{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  impure.eww =
    let
      rust-overlay = import (pkgs.fetchFromGitHub {
        owner = "oxalica";
        repo = "rust-overlay";
        rev = "9824f142cbd7bc3e2a92eefbb79addfff8704cd3";
        sha256 = "sha256-RumRrkE6OTJDndHV4qZNZv8kUGnzwRHZQSyzx29r6/g=";
      });
    in
    pkgs.callPackage ./pkgs/eww {
      pkgs = pkgs.extend rust-overlay;
    };

  bling = pkgs.callPackage ./pkgs/bling {
    inherit (pkgs.lua53Packages) lua toLuaModule;
  };

  iosevka-ft-bin = pkgs.callPackage ./pkgs/iosevka-ft-bin { };

  abstractdark-sddm-theme = pkgs.callPackage ./pkgs/abstractdark-sddm-theme { };

  simber = pkgs.callPackage ./pkgs/simber { };

  pydes = pkgs.callPackage ./pkgs/pydes { };

  downloader-cli = pkgs.callPackage ./pkgs/downloader-cli { };

  itunespy = pkgs.callPackage ./pkgs/itunespy { };

  youtube-search = pkgs.callPackage ./pkgs/youtube-search { };

  ytmdl = pkgs.callPackage ./pkgs/ytmdl {
    inherit itunespy simber pydes downloader-cli youtube-search;
    inherit (pkgs.python3Packages) buildPythonPackage fetchPypi;
  };
}
