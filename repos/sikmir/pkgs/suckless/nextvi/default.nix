{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2025-03-18";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "942c6b17ecaf2e0df916b2d31391c1e81493c972";
    hash = "sha256-lfB/u5aLhCzv7sISOZYbTscNF6AXJL/iZ2ZQMGnV+CU=";
  };

  buildPhase = ''
    runHook preBuild
    sh ./cbuild.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    PREFIX=$out sh ./cbuild.sh install
    runHook postInstall
  '';

  meta = {
    description = "Next version of neatvi (a small vi/ex editor)";
    homepage = "https://github.com/kyx0r/nextvi";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
