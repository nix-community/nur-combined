{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gopro-labs-udtacopy";
  version = "0-unstable-2026-09-07";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "gopro";
    repo = "labs";
    rev = "6092f88bc628053a4bce87c1f97c8d155cfa953a";
    hash = "sha256-eiT3PrOmwS+nw31s4Njtv0Tlr+COhkSoe6DJrYyoVJc=";
  };

  sourceRoot = "source/docs/control/chapters/src";

  nativeBuildInputs = [
    cmake
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -v udtacopy $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GoPro camera tool to copy global GPMF data from an MP4 to another";
    homepage = "https://github.com/gopro/labs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "udtacopy";
    platforms = lib.platforms.all;
  };
})
