{
  sources,
  lib,
  stdenvNoCC,
  dos2unix,
  unzip,
  ...
}:
let
  configFile = ./config_local.php;
in
stdenvNoCC.mkDerivation {
  inherit (sources.calibre-cops) pname version src;

  unpackPhase = ''
    unzip $src
  '';

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    mkdir $out
    cp -r * $out/
    cp ${configFile} $out/config_local.php
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Calibre OPDS (and HTML) PHP Server : web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks (epub, mobi, pdf, ...)";
    homepage = "http://blog.slucas.fr/en/oss/calibre-opds-php-server";
    license = licenses.gpl2Only;
  };
}
