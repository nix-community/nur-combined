{
  stdenv,
  fetchFromGitHub,
  lib,
  dataPath ? "/var/lib/xauth-server/data/",
  svgBanner ? null,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-xauth-server-${version}";
  version = "78caf02";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "xauth-server";
    rev = "78caf0277d12e0c8f0824f4c3a20415d8dbfcaa6";
    hash = "sha256-RvuGlxoWHtPRmdqHpFNTscXfFK+Mu0gUlzOnKQBozt4=";
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
