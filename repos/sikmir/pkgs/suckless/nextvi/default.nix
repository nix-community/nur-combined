{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2025-05-20";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "9e682035a2b7ad67d7e000f9c7ca6075e211109c";
    hash = "sha256-4PX8fg4rHXuNGSuYWdkgCGgpz1vh8Zm4HkwKJkP2kDg=";
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
