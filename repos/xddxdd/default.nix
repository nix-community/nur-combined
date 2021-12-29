# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bird-lg-go = pkgs.callPackage ./pkgs/bird-lg-go { };
  bird-lgproxy-go = pkgs.callPackage ./pkgs/bird-lgproxy-go { };
  boringssl-oqs = pkgs.callPackage ./pkgs/boringssl-oqs {
    inherit liboqs;
  };
  chmlib-utils = pkgs.callPackage ./pkgs/chmlib-utils { };
  coredns = pkgs.callPackage ./pkgs/coredns { };
  dngzwxdq = pkgs.callPackage ./pkgs/dngzwxdq {
    inherit chmlib-utils;
  };
  dnyjzsxj = pkgs.callPackage ./pkgs/dnyjzsxj {
    inherit chmlib-utils;
  };
  ftp-proxy = pkgs.callPackage ./pkgs/ftp-proxy { };
  genshin-checkin-helper = pkgs.callPackage ./pkgs/genshin-checkin-helper {
    inherit genshinhelper2 onepush;
  };
  genshinhelper2 = pkgs.callPackage ./pkgs/genshinhelper2 { };
  libltnginx = pkgs.callPackage ./pkgs/libltnginx { };
  liboqs = pkgs.callPackage ./pkgs/liboqs { };
  linux-xanmod-lantian = pkgs.callPackage ./pkgs/linux-xanmod-lantian {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
  onepush = pkgs.callPackage ./pkgs/onepush { };
  openresty-lantian = pkgs.callPackage ./pkgs/openresty-lantian {
    inherit liboqs boringssl-oqs;
  };
  qemu-user-static = pkgs.callPackage ./pkgs/qemu-user-static { };
  rime-dict = pkgs.callPackage ./pkgs/rime-dict { };
  rime-moegirl = pkgs.callPackage ./pkgs/rime-moegirl { };
  rime-zhwiki = pkgs.callPackage ./pkgs/rime-zhwiki { };
  route-chain = pkgs.callPackage ./pkgs/route-chain { };
  xray = pkgs.callPackage ./pkgs/xray { };
}
