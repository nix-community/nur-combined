{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nextvi";
  version = "2022-07-17";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "7c9f5b609ae95cc85916366d1880ac2c91b31e84";
    hash = "sha256-6MfX9oj7obr83+azPA1hmQzM6ACzqCOGCsZ3nfpzvEg=";
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
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
