{ pkgs ? import <nixpkgs> { } }:

let
  stdenv = pkgs.clangStdenv;
in
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  impure.eww =
    let
      rust-overlay = import (pkgs.fetchFromGitHub {
        owner = "oxalica";
        repo = "rust-overlay";
        rev = "98e706440e250f6e5c5a7f179b0fc1e7f6270bd5";
        sha256 = "sha256-b9q+/LMIMIL2zq0PSt2cYFnDnMHNlYxoSsXxptLe3ac=";
      });

    in
    pkgs.callPackage ./pkgs/eww {
      pkgs = pkgs.extend rust-overlay;
    };

  bling = pkgs.callPackage ./pkgs/bling {
    inherit stdenv;
    inherit (pkgs) fetchFromGitHub;
    inherit (pkgs.lua53Packages) lua toLuaModule;
  };

  iosevka-ft-bin = pkgs.callPackage ./pkgs/iosevka-ft-bin {
    inherit (pkgs) fetchFromGitHub;
  };

  abstractdark-sddm-theme = pkgs.callPackage ./pkgs/abstractdark-sddm-theme {
    inherit stdenv;
    inherit (pkgs) fetchFromGitHub;
  };

  simber = pkgs.callPackage ./pkgs/simber {
    inherit (pkgs) python3Packages;
  };

  pydes = pkgs.callPackage ./pkgs/pydes {
    inherit (pkgs) python3Packages;
  };

  downloader-cli = pkgs.callPackage ./pkgs/downloader-cli {
    inherit (pkgs) fetchFromGitHub python3Packages;
  };

  itunespy = pkgs.callPackage ./pkgs/itunespy {
    inherit (pkgs) python3Packages;
  };

  youtube-search = pkgs.callPackage ./pkgs/youtube-search {
    inherit (pkgs) python3Packages;
  };

  ytmdl = pkgs.callPackage ./pkgs/ytmdl {
    inherit itunespy simber pydes downloader-cli youtube-search;
    inherit (pkgs) python3Packages;
    inherit (pkgs.python3Packages) buildPythonPackage fetchPypi;
  };
}
