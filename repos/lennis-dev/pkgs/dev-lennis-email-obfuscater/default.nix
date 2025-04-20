{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-email-obfuscater-${version}";
  version = "3ac40a4";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "email-obfuscater";
    rev = "3ac40a4d90f453342a9f2d6b89b2ddc22591fa4a";
    hash = "sha256-pJ6HkvUzC4SxUgxlCl3AFqmOkqmaUVeEtvikzHKQ4Lg=";
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
