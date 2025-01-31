{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
}:

stdenv.mkDerivation {
  pname = "unum";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "Fourmilab";
    repo = "unum";
    rev = "5a7851baa76e125f4b59a2f28a23d2e52ed270f2";
    hash = "sha256-sHWpLJ7PHPPB+Vcgw1eHReTo2U9yCpJrYlMkfXhmuFM=";
  };

  buildInputs = [ perl ];

  makeFlags = [ "unum" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 unum/unum.pl $out/bin/unum

    runHook postInstall
  '';

  meta = {
    description = "Utility for looking up Unicode characters and HTML entities by code, name, block, or description";
    homepage = "https://github.com/Fourmilab/unum";
    license = lib.licenses.cc-by-sa-40;
    mainProgram = "unum";
  };
}
