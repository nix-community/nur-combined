{
  lib,
  stdenvNoCC,
  sources,
}:
let
  configFile = ./config.inc.php;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.phpmyadmin) pname version src;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out/
    rm -rf $out/config.sample.inc.php $out/examples $out/setup $out/sql
    cp ${configFile} $out/config.inc.php

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Web interface for MySQL and MariaDB";
    homepage = "https://www.phpmyadmin.net/";
    license = lib.licenses.gpl2Only;
  };
})
