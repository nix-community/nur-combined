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
      rev = "1d38b7c3bb2f317b935f20ac7e01db93b151770f";
      sha256 = "sha256-mjTR3dgUrha4tqNpEEYUXx38wXlUp4ftlhx4wfQmrzs=";
    }).out;
    
  in pkgs.callPackage ./pkgs/eww {
    pkgs = pkgs.extend rust-overlay;
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
