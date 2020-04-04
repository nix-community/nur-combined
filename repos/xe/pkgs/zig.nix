{ pkgs ? import <nixpkgs> { } }:

version: shasums:

let
  attrs = if pkgs.stdenv.isDarwin then {
    url = "https://ziglang.org/builds/zig-macos-x86_64-${version}.tar.xz";
    sha256 = shasums.mac;
  } else {
    url = "https://ziglang.org/builds/zig-linux-x86_64-${version}.tar.xz";
    sha256 = shasums.linux;
  };

  src = pkgs.fetchurl attrs;

in pkgs.stdenv.mkDerivation {
  name = "zig";
  inherit src version;

  installPhase = ''
    mkdir -p $out
    cp -rf * $out
    mkdir -p $out/bin
    mv $out/zig $out/bin/zig
  '';
}
