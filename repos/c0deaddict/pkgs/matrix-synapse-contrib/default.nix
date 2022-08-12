{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = "1.64.0";

  src = fetchFromGitHub rec {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "sha256-EXOez0FqVIwOcnqf/6vjc81ob8DoAyRfF+WqLnGp2lQ=";
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
