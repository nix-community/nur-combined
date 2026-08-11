{
  lib,
  stdenv,
  fetchfossil,
  php,
}:

stdenv.mkDerivation rec {
  pname = "versionnum";
  version = "3.2.7";

  src = fetchfossil {
    url = "http://fossil.include-once.org/versionnum";
    rev = "b62946f7b1ea3d05644920ea43591192e7eb4422";
    hash = "sha256-qAh8QMzQ/Rb64qTjWwAmol3PvbGN7qemE5sPGV5pv4o=";
  };

  buildInputs = [
    php
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp version.php $out/bin/version
  '';

  meta = {
    description = "update version numbers across source code files";
    homepage = "http://fossil.include-once.org/versionnum";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "version";
    platforms = lib.platforms.all;
  };
}
