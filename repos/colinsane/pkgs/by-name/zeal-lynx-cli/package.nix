{
  lib,
  lynx,
  fetchFromGitLab,
  python3,
  stdenv,
  unstableGitUpdater,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "zeal-lynx-cli";
  version = "0-unstable-2023-02-27";

  src = fetchFromGitLab {
    owner = "ivan-cukic";
    repo = "zeal-lynx-cli";
    rev = "1bf364389877fe87bd5c9d3e4177426304be2ddc";
    hash = "sha256-ob9wOwhSZK0psqHr/GcjiYHO0JRFL04zRAm3/QlPc3g=";
  };

  nativeBuildInputs = [
    python3.pkgs.wrapPython
  ];

  buildInputs = [
    lynx
  ];

  propagatedBuildInputs = [
    python3.pkgs.beautifulsoup4
    python3.pkgs.xdg
  ];

  postPatch = ''
    substituteInPlace zeal-cli \
      --replace-fail '#!/bin/python3'  '#!/usr/bin/env python3'
  '';

  postInstall = ''
    mkdir -p $out/bin
    cp zeal-cli $out/bin
  '';

  postFixup = ''
    makeWrapperArgs+=(
      "--suffix" "PATH" ":" "${lib.makeBinPath [ lynx ]}"
    )
    wrapPythonPrograms
  '';

  doCheck = true;

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://gitlab.com/ivan-cukic/zeal-lynx-cli";
    mainProgram = "zeal-cli";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
