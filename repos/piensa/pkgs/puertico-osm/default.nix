{ stdenv, fetchgit, coreutils, bash }:

stdenv.mkDerivation {
  name = "puertico-osm";
  builder = "${bash}/bin/bash"; args = [ ./builder.sh ];
  inherit coreutils;
  src = fetchgit { 
    url = "https://github.com/piensa/puertico-osm";
    rev = "7d09644b8a73ed354a862e154f5a98dbdbe57577";
    sha256 = "0z6h07my5g1ma854frpyxy8pw6miz0rmbxpbc00yw3xh6acqa8xl";
  };
}

