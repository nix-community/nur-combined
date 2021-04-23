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
      rev = "2dffb6e3a8d665d8b7d12569a30e70f763efe002";
      sha256 = "sha256-FRpeaxpfq2WZlz21bqCoiFv1c1f2vh1ZCsA9XYczgy4=";
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
    inherit bs4 itunespy simber pydes downloader-cli youtube-search;
    inherit (pkgs) python3Packages;
  };
}
