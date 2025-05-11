{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2025-04-17";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "7e546680836dfee8eb862462d3688a58a9954b71";
    hash = "sha256-KTR7E2reoWVHlBmagJfafcaPUnL9+zSrQNanZCIfgDY=";
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
