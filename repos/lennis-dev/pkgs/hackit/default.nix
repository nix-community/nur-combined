{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-hackit-${version}";
  version = "fb6949d";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "hackit";
    rev = "fb6949d1ffe3d74aee821ca939e83b22c617977c";
    hash = "sha256-KCFpN9RlXZWEb4n4Tqq/Ywd605PSLUgSaAgSItjnMW0=";
  };

  update-my-nur = true;

  installPhase = ''
    mkdir -p $out/www
    shopt -s dotglob
    cp -r ${src}/* $out/www
  '';

  meta = with lib; {
    description = "This is a simple web application that allows users to try and solve a series of challenges. The challenges are designed to test the user's knowledge of web security and programming. The application is written in PHP. ";
    license = licenses.mit;
    homepage = "https://hackit.lennis.dev/";
  };
}
