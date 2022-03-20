{ lib
, stdenv
, sources
, ...
} @ args:

let
  configFile = ./config.inc.php;
in
stdenv.mkDerivation rec {
  inherit (sources.phpmyadmin) pname version src;

  installPhase = ''
    mkdir $out
    cp -r * $out/
    rm -rf $out/config.sample.inc.php $out/examples $out/setup $out/sql
    cp ${configFile} $out/config.inc.php
  '';
}
