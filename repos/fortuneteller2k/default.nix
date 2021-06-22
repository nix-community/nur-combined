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

  awesome-git = with pkgs; (awesome.overrideAttrs (old: rec {
    src = fetchFromGitHub {
      owner = "awesomeWM";
      repo = "awesome";
      rev = "6b97ec33071790e66719773bfc280f34a17fef25";
      sha256 = "1ail2aks699db064adiw4s5ipyj1yw4hmxy1xhgdi2dpshfkcp76";
    };

    GI_TYPELIB_PATH = "${playerctl}/lib/girepository-1.0:"
      + "${upower}/lib/girepository-1.0:" + old.GI_TYPELIB_PATH;
  })).override {
    stdenv = clangStdenv;
    luaPackages = lua52Packages;
    gtk3Support = true;
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
