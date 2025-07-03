{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2025-06-25";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "b13e79ed17f20833d2261c2e35de8fc3795c6f78";
    hash = "sha256-05qEr15MmlglAhgekr9wbsbG4xYAifF7lIdWtzNmDbs=";
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
    mainProgram = "vi";
  };
})
