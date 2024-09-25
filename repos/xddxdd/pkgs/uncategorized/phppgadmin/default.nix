{
  lib,
  stdenvNoCC,
  sources,
  ...
}:
let
  configFile = ./config.inc.php;
in
stdenvNoCC.mkDerivation rec {
  inherit (sources.phppgadmin) pname version src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/
    find $out -type f -exec chmod 644 {} +
    find $out -type d -exec chmod 755 {} +
    rm -rf $out/conf/config.inc.php-dist
    cp ${configFile} $out/conf/config.inc.php

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "The premier web-based administration tool for PostgreSQL";
    homepage = "https://github.com/phppgadmin/phppgadmin";
    license = licenses.gpl2Only;
  };
}
