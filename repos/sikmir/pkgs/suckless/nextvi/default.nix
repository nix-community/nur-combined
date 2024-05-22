{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2024-04-29";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "01f4dff99aab251ea502d17edcde5b16c0807977";
    hash = "sha256-fKrlIgK5fCDh+WQyLpcF+k8NKOriJbGF3OVUwN/Ld78=";
  };

  buildPhase = ''
    runHook preBuild
    sh ./build.sh
    runHook postBuild
  '';

  installPhase = ''
    PREFIX=$out sh ./build.sh install
  '';

  meta = with lib; {
    description = "Next version of neatvi (a small vi/ex editor)";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
})
