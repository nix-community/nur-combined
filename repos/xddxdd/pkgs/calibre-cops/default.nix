{ lib
, stdenvNoCC
, fetchurl
, unzip
, dos2unix
, ...
} @ args:

let
  configFile = ./config_local.php;
in
stdenvNoCC.mkDerivation rec {
  pname = "calibre-cops";
  version = "1.1.3";
  src = fetchurl {
    url = "https://github.com/seblucas/cops/releases/download/${version}/cops-${version}.zip";
    sha256 = "sha256-aMnvs0CrMJic2JoZoXPEWHLTPthd0CZ0+K8It3SMvHc=";
  };

  nativeBuildInputs = [ unzip dos2unix ];

  prePatch = ''
    dos2unix vendor/seblucas/dot-php/doT.php
  '';
  patches = [ ./php80-fix.patch ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir $out
    cp -r * $out/
    cp ${configFile} $out/config_local.php
  '';

  meta = with lib; {
    description = "Calibre OPDS (and HTML) PHP Server : web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks (epub, mobi, pdf, ...)";
    homepage = "http://blog.slucas.fr/en/oss/calibre-opds-php-server";
    license = licenses.gpl2;
  };
}
