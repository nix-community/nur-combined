{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = "1.56.0";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "sha256-rzS2u5TkmwEb1cs7MwO/HrEmn1VHnrku9Q7Gw6CesOs=";
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
