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
  inherit (sources.phpmyadmin) pname version src;

  installPhase = ''
    mkdir $out
    cp -r * $out/
    rm -rf $out/config.sample.inc.php $out/examples $out/setup $out/sql
    cp ${configFile} $out/config.inc.php
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A web interface for MySQL and MariaDB";
    homepage = "https://www.phpmyadmin.net/";
    license = licenses.gpl2Only;
  };
}
