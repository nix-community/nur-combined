{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "506b29c1ef7a8d267a5a398541cfc573c8948824";
    hash = "sha256-xIXrRYHz9YRi0Tz5H3uelHS9cTju67cV1fxazw09Aic=";
  };

  buildPhase = ''
    runHook preBuild
    sh ./build.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    PREFIX=$out sh ./build.sh install
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
