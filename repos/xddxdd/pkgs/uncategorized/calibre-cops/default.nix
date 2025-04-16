{
  sources,
  lib,
  stdenvNoCC,
  unzip,
}:
let
  configFile = ./config_local.php;
in
stdenvNoCC.mkDerivation rec {
  inherit (sources.calibre-cops) pname version src;

  unpackPhase = ''
    runHook preUnpack

    unzip $src

    runHook postUnpack
  '';

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out/
    cp ${configFile} $out/config/local.php

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/mikespub-org/seblucas-cops/releases/tag/${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Calibre OPDS (and HTML) PHP Server : web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks (epub, mobi, pdf, ...)";
    homepage = "http://blog.slucas.fr/en/oss/calibre-opds-php-server";
    license = lib.licenses.gpl2Only;
  };
}
