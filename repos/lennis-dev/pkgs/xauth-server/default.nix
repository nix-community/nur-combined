{
  stdenv,
  fetchFromGitHub,
  lib,
  dataPath ? "/var/lib/xauth-server/data/"
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-xauth-server-${version}";
  version = "076c4ac";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "xauth-server";
    rev = "076c4ac33d5836aebb7f5ef90e803aed2d7fb7ea";
    hash = "sha256-ci9ddVKG1wjiiJ29tSaRk6we/bWF5Iu28hZ4OUf4IPw=";
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
  '';

  meta = with lib; {
    description = "Lennis.dev website";
    license = licenses.mit;
    homepage = "https://www.lennis.dev/";
  };
}
