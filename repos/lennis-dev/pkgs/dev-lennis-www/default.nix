{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-www-${version}";
  version = "f2d4f01";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "lennis.dev";
    rev = "f2d4f016b8ce9e5680426266ec6edf4ce728d669";
    hash = "sha256-ozjx753uhJ869UW+DHtoRP9pYXVLJBEABwjrqy1gK0I=";
  };

  installPhase = ''
    mkdir -p $out/www
    shopt -s dotglob
    cp -r ${src}/* $out/www
  '';

  meta = with lib; {
    description = "Lennis.dev website";
    license = licenses.mit;
    homepage = "https://www.lennis.dev/";
  };
}
