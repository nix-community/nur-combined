{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-www-${version}";
  version = "77e7d3f";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "lennis.dev";
    rev = "77e7d3fafccd37dba425446b441541f7a5d9454d";
    hash = "sha256-UsOFAdDTfn7ED4LqjJ/cpRUD7R/kCQHoX//NpRklUYQ=";
  };

  update-my-nur = true;

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
