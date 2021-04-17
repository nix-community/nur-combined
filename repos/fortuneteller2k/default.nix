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
      rev = "38766381042021f547a168ebb3f10305dc6fde08";
      sha256 = "02w2xgavv4zk0rz3b6jsjknll2a3632xv6c67dd95zaw173y35gl";
    });
    
  in pkgs.callPackage ./pkgs/eww {
    pkgs = pkgs.extend rust-overlay;
  };

  iosevka-ft-bin = pkgs.callPackage ./pkgs/iosevka-ft-bin {
    fetchFromGitHub = pkgs.fetchFromGitHub;
  };

  abstractdark-sddm-theme = pkgs.callPackage ./pkgs/abstractdark-sddm-theme {
    inherit stdenv;
    fetchFromGitHub = pkgs.fetchFromGitHub;
  };

  bs4 = pkgs.callPackage ./pkgs/bs4 {
    python3Packages = pkgs.python3Packages;
  };

  simber = pkgs.callPackage ./pkgs/simber {
    python3Packages = pkgs.python3Packages;
  };
  
  pydes = pkgs.callPackage ./pkgs/pydes {
    python3Packages = pkgs.python3Packages;
  };
  
  downloader-cli = pkgs.callPackage ./pkgs/downloader-cli {
    fetchFromGitHub = pkgs.fetchFromGitHub;
    python3Packages = pkgs.python3Packages;
  };
  
  itunespy = pkgs.callPackage ./pkgs/itunespy {
    python3Packages = pkgs.python3Packages;
  };
  
  youtube-search = pkgs.callPackage ./pkgs/youtube-search {
    python3Packages = pkgs.python3Packages;
  };

  ytmdl = pkgs.callPackage ./pkgs/ytmdl {
    inherit bs4 itunespy simber pydes downloader-cli youtube-search;
    python3Packages = pkgs.python3Packages;
  };
}
