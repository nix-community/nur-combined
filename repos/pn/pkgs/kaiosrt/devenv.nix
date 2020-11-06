{ stdenv, buildEnv, callPackage }:
let
  kaiosrt = callPackage ./default.nix { };
  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/916f6583a9f7952230737b7ef29b3e4b05f148f1.tar.gz";
    sha256 = "1vg4kg1aqfxgvwqb8mpkbnml5cxcchw9jck1if2b1kjarsllazbr";
  }) { };
  firefox59 = nixpkgs.firefox-devedition-bin;
  palemoon28 = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/9a38937331c97f974a2490990e1aed3cb8b0464c.tar.gz";
    sha256 = "0c0g0xkjfpxy0xzbqkkfwy89yqsppqj7x41qjhx85inq5g267d86";
  }) {}).palemoon;
in
  buildEnv {
    name = "kaios-devenv";
    paths = [
      kaiosrt
      firefox59
      palemoon28
    ];

    meta = {
      license = {
        free = false;
      };
    };
  }
