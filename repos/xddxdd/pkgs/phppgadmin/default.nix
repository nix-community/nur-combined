{ lib
, stdenv
, sources
, ...
} @ args:

let
  configFile = ./config.inc.php;
in
stdenv.mkDerivation rec {
  inherit (sources.phppgadmin) pname version src;

  patches = [
    ./fix-virtual-class-cannot-instantiate.patch
  ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    find $out -type f -exec chmod 644 {} +
    find $out -type d -exec chmod 755 {} +
    rm -rf $out/conf/config.inc.php-dist
    cp ${configFile} $out/conf/config.inc.php
  '';

  meta = with lib; {
    description = "The premier web-based administration tool for PostgreSQL";
    homepage = "https://github.com/phppgadmin/phppgadmin";
    license = licenses.gpl2;
  };
}
