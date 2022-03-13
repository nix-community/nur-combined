{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = "1.54.0";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = "sha256-9oZIEomv1N6QWSTyeQ99H7mf3paW4oVoYqiVGc4jbEU=";
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
