{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = matrix-synapse.version;

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = {
      "1.53.0" = "sha256-aChofKpBQy+HQCTW9yNV+F03MpSyDaszz86H/pJGm00=";
    }.${version};
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
