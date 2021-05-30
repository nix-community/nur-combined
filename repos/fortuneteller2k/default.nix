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
        rev = "b7eb21a494aab17dca98e121333921f55a6361fd";
        sha256 = "sha256-VoHaAI1lfM3WoEOeCU5KNjsMZhfsmBnU+2QEEIAztaQ=";
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
