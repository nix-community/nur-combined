{ lib
, stdenv
, sources
, ...
} @ args:

let
  configFile = ./config_local.php;
in
stdenv.mkDerivation rec {
  inherit (sources.calibre-cops) pname version src;

  installPhase = ''
    mkdir $out
    cp -r * $out/
    cp ${configFile} $out/config_local.php
  '';
}
