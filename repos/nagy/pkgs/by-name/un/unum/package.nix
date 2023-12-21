{ lib, stdenv, fetchFromGitHub, perl }:

stdenv.mkDerivation rec {
  pname = "unum";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "Fourmilab";
    repo = pname;
    rev = "2e544ef429768ad7c491cbbac1ca9742e310c2f0";
    hash = "sha256-fAegRn95n+0M5ISKP1xrkXJNJiF+qFjtkIXYV3f/4pQ=";
  };

  buildInputs = [ perl ];

  makeFlags = [ "unum" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 unum/unum.pl $out/bin/unum

    runHook postInstall
  '';

  meta = {
    description =
      "Utility for looking up Unicode characters and HTML entities by code, name, block, or description";
    homepage = "https://github.com/Fourmilab/unum";
    license = lib.licenses.cc-by-sa-40;
    mainProgram = "unum";
  };
}
