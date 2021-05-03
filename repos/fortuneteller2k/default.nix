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
      rev = "d9a12fdf65157656348ea67456c5bfec39f50f73";
      sha256 = "sha256-lXs7JuyfrJUNlDvrXV0E+0mN7CHUSFp9+wgBQIz1SiE=";
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
