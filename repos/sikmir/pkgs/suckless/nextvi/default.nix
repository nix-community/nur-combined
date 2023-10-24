{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextvi";
  version = "2023-10-23";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "0160364bb797e4155ef14d95c29df2730b4d9169";
    hash = "sha256-D9aq129X/Y1jRd9dejEUJk+6md7IRrqOS0Eulvj6Dyw=";
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
