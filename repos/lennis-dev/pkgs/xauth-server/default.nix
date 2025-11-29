{
  stdenv,
  fetchFromGitHub,
  lib,
  dataPath ? "/var/lib/xauth-server/data/",
  svgBanner ? null,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-xauth-server-${version}";
  version = "16eaded";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "xauth-server";
    rev = "16eadedecee541828091145fd7cdfd9cfc33f9b0";
    hash = "sha256-xLA9Qo2kPBUA0355NU9s1I7GgYnxWyZdKa39ZPZ6VFc=";
  };

  update-my-nur = true;

  configContent = ''
    <?php

    \$config = array(
        \"dataDir\" => \"${dataPath}\",
    );
  '';

  installPhase = ''
    mkdir -p $out/www
    shopt -s dotglob
    cp -r ${src}/* $out/www/
    echo "${configContent}" > $out/www/config.php
    ${lib.optionalString (svgBanner != null) "cp '${svgBanner}' $out/www/assets/img/banner.svg"}
  '';

  meta = with lib; {
    description = "The server handling single sign-on and authentication for Lennis.dev services.";
    license = licenses.mit;
    homepage = "https://auth.lennis.dev/";
  };
}
