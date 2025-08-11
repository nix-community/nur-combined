{
  python3,
  fetchFromGitHub,
  stdenv,
  lib
}:
let
  python3-env = (python3.withPackages (ps: with ps; [
    flask-cors
    flask
    requests
    python-dateutil
    psycopg
    psycopg-pool
  ]));
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tulip-api";
  version = "1.0.1-2025.07.03.unstable";

  src = fetchFromGitHub {
    owner = "OpenAttackDefenseTools";
    repo = "tulip";
    rev = "86f62ee5a73e8080af31bb7c27b8c89e6b16d342";
    hash = "sha256-xJCesNowkPqPP+mkUykSAkN+vKuasVVqBUp8vmYWKms=";
  };

  patches = [
    ./config.patch
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r services/api $out/tulip-api
    mkdir -p $out/bin
    substituteInPlace $out/tulip-api/webservice.py \
      --replace-fail \
        '#!/usr/bin/env python3' \
        '#!${python3-env.interpreter}'
    chmod +x $out/tulip-api/webservice.py
    ln -s $out/tulip-api/webservice.py $out/bin/tulip-api
    chmod +x $out/bin/tulip-api

    runHook postInstall
  '';

  meta = {
    description = "Network analysis tool for Attack Defence CTF";
    homepage = "https://github.com/OpenAttackDefenseTools/tulip/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "tulip-api";
  };
})
