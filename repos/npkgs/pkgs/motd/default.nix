{ stdenv, pkgs ? import <nixpkgs> {} }:

stdenv.mkDerivation {
  pname = "motd";
  version = "v0.1.0";
  src = ./motd;

  unpackPhase = ''
    cp $src motd
  '';
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp motd $out/bin/motd
  '';
}
