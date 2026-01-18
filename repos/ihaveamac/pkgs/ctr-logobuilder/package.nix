{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "ctr-logobuilder";
  version = "0-unstable-2015-11-25";

  src = fetchFromGitHub {
    owner = "yellows8";
    repo = pname;
    rev = "3f69b644d8c26d69da0de8e479140c12fdbd5f2b";
    hash = "sha256-17v6Qmtq9C3VaWR1XbnOgz9gbvioi1g6FbiEceZeDx4=";
  };

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -o ctr-logobuilder ctr-logobuilder.c utils.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ctr-logobuilder${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "Build 3DS logo files";
    homepage = "https://github.com/yellows8/ctr-logobuilder";
    platforms = platforms.all;
    mainProgram = "ctr-logobuilder";
  };
}
