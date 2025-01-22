{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "cxxmatrix";
  version = "0-unstable-2024-06-17";

  src = fetchFromGitHub {
    owner = "akinomyoga";
    repo = "cxxmatrix";
    rev = "c8d4ecfb8b6c22bb93f3e10a9d203209ba193591";
    sha256 = "sha256-5f0frZc5okqBhSU5wuv33DflvK9enBjmTSaUviaAFGo=";
  };

  outputs = [
    "out"
    "man"
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "The Matrix Reloaded in Terminals";
    homepage = "https://github.com/akinomyoga/cxxmatrix";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "cxxmatrix";
  };
}
