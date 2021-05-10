{ pkgs ? import <nixpkgs> { } }:

let
  stdenv = pkgs.clangStdenv;
in
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  impure.eww = let 
    rust-overlay = import (pkgs.fetchFromGitHub {
      owner = "oxalica";
      repo = "rust-overlay";
      rev = "7ad612694103fa3a3e6d06bc3e7c1a0a62856e5f";
      sha256 = "sha256-ju70leih5XINXymlQMbj+tmQ6OwIbpIBt+8L0IAd8kQ=";
    });
    
  in pkgs.callPackage ./pkgs/eww {
    pkgs = pkgs.extend rust-overlay;
  };

  iosevka-ft-bin = pkgs.callPackage ./pkgs/iosevka-ft-bin {
    inherit (pkgs) fetchFromGitHub;
  };

  abstractdark-sddm-theme = pkgs.callPackage ./pkgs/abstractdark-sddm-theme {
    inherit stdenv;
    inherit (pkgs) fetchFromGitHub;
  };

  bs4 = pkgs.callPackage ./pkgs/bs4 {
    inherit (pkgs) python3Packages;
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
