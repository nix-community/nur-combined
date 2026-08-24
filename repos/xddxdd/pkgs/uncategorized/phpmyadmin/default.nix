{
  fetchurl,
  lib,
  stdenv,
}:
let
  configFile = ./config.inc.php;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "phpmyadmin";
  version = "5.2.3";
  src = fetchurl {
    url = "https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.tar.xz";
    hash = "sha256-V4gTSCl8RBL4bEEFR892tNiiNldN0sa31qK+6+f8ROM=";
  };
  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out/
    rm -rf $out/config.sample.inc.php $out/examples $out/setup $out/sql
    cp ${configFile} $out/config.inc.php

    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Web interface for MySQL and MariaDB";
    homepage = "https://www.phpmyadmin.net/";
    license = lib.licenses.gpl2Only;
  };
})
