{ stdenv, fetchurl, smarty3 }:

stdenv.mkDerivation rec {
  pname = "self-service-password";
  version = "1.8.2";

  src = fetchurl {
    url = "https://ltb-project.org/archives/ltb-project-${pname}-${version}.tar.gz";
    hash = "sha256-Ujq5fU7zU1weOCgGtxivh8rY2LvfwQP4h4JUGdcP/pc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/self-service-password
    cp -ra . $out/share/self-service-password

    substituteInPlace $out/share/self-service-password/conf/config.inc.php \
      --replace-fail "/usr/share/php/smarty3" "${smarty3}"

    ln -sf /etc/self-service-password/config.inc.local.php \
      $out/share/self-service-password/conf/config.inc.local.php

    runHook postInstall
  '';
}
