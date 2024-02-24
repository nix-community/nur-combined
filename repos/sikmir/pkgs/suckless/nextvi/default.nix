{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "0-unstable-2024-02-18";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "31c890ef8adb0e729249ea818c283bf143b98e84";
    hash = "sha256-fo0k3zN+werG4WnhYwj9taWNstB8ypVknWagtYUWiHs=";
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
