{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
}:
let
  python3-env = (python3.withPackages (ps: with ps; [
    requests
    psycopg
    psycopg-pool
  ]));
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tulip-flagids";
  version = "1.0.1-2025.07.03.unstable";

  src = fetchFromGitHub {
    owner = "OpenAttackDefenseTools";
    repo = "tulip";
    rev = "86f62ee5a73e8080af31bb7c27b8c89e6b16d342";
    hash = "sha256-xJCesNowkPqPP+mkUykSAkN+vKuasVVqBUp8vmYWKms=";
  };

  patches = [
    ./flagids_time.patch
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp services/flagids/flagids.py $out/bin/tulip-flagids
    substituteInPlace $out/bin/tulip-flagids \
      --replace-fail \
        '#!/bin/env python' \
        '#!${python3-env.interpreter}'
    chmod +x $out/bin/tulip-flagids

    runHook postInstall
  '';

  meta = {
    description = "Network analysis tool for Attack Defence CTF";
    homepage = "https://github.com/OpenAttackDefenseTools/tulip/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "tulip-flagids";
  };
})
