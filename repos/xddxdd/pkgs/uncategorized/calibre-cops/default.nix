{
  sources,
  lib,
  stdenvNoCC,
  unzip,
}:
let
  configFile = ./config_local.php;
in
stdenvNoCC.mkDerivation (finalAttrs: {
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
    changelog = "https://github.com/mikespub-org/seblucas-cops/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks";
    homepage = "http://blog.slucas.fr/en/oss/calibre-opds-php-server";
    license = lib.licenses.gpl2Only;
  };
})
