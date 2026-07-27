{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "blockquote";
  version = "2017-08-25";

  src = fetchzip {
    url = "https://github.com/dokufreaks/plugin-blockquote/archive/refs/tags/${version}.zip";
    hash = "sha256-SzOXlRkOkI/RDdUQDR3IuzRXN+379jxeFsN4r9g9Gic=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
