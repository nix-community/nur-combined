{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2024-08-27";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "183c72073325deecec40c20a532df7271d268082";
    hash = "sha256-CQXJITy3bkzcnfGzTLE9aApWbrTjeyeLqC7wM5aAidQ=";
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
