{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2025-07-20";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "766265f542c2f55f07194101a768526703d56275";
    hash = "sha256-mTiLQSOzPqow+4eOlx1fysvRL7g+6ZIuIZk7xdTuEdY=";
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
