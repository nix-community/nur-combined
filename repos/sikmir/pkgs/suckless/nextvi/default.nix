{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "2023-11-30";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "2ff52843c81ab1c11b534b8107ed9bfa160ab69f";
    hash = "sha256-qXI0LnH/NRG9fRetymkkg5ESxSLuYMLewzYwvgyU7TU=";
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
