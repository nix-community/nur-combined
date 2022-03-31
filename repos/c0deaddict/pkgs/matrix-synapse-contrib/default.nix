{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = "1.55.0";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "sha256-ddrb+Py2I1JxKdiMx7f+1imO4gA76WH+Nbqf5JtaL3s=";
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
