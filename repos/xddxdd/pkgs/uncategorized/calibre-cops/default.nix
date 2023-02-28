{
  sources,
  lib,
  stdenvNoCC,
  dos2unix,
  unzip,
  ...
} @ args: let
  configFile = ./config_local.php;
in
  stdenvNoCC.mkDerivation {
    inherit (sources.calibre-cops) pname version src;

    unpackPhase = ''
      unzip $src
    '';

    nativeBuildInputs = [dos2unix unzip];

    prePatch = ''
      dos2unix vendor/seblucas/dot-php/doT.php
    '';
    patches = [./php80-fix.patch];

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
