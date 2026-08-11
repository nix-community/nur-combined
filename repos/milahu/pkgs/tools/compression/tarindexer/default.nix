# TODO package as python module, so we can do
/*
import tarindexer
tarindexer.indextar(dbtarfile, indexfile)
tarindexer.lookup(dbtarfile, indexfile, path)
*/

{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "tarindexer";
  version = "unstable-2015-07-27";

  src = fetchFromGitHub {
    owner = "devsnd";
    repo = "tarindexer";
    rev = "44ca968b6eedeec5ad03dd63a8b7d7a2221af03a";
    hash = "sha256-hPkoJfjH0AkKSAz4CseVPsfxaHR1LugOD3FFVQNtCIU=";
  };

  buildInputs = [
    python3
  ];

  installPhase = ''
    substituteInPlace tarindexer.py \
      --replace \
        '#!/usr/bin/python3' \
        '#!/usr/bin/env python3'
    chmod +x tarindexer.py
    mkdir -p $out/bin
    cp tarindexer.py $out/bin/tarindexer
  '';

  meta = {
    description = "Python module for indexing tar files for fast access";
    homepage = "https://github.com/devsnd/tarindexer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "tarindexer";
    platforms = lib.platforms.all;
  };
}
