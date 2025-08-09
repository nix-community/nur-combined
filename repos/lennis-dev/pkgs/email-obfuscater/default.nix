{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-email-obfuscater-${version}";
  version = "115ed59";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "email-obfuscater";
    rev = "115ed594ea157447d8141d9f53e1ad9ed51db538";
    hash = "sha256-iAJOqDyG4y9UIJ3cGSWI61cKC0nawfbEPASRXkLgJ7o=";
  };

  installPhase = ''
    mkdir -p $out/www
    shopt -s dotglob
    cp -r ${src}/* $out/www
  '';

  meta = with lib; {
    description = "Obfuscate email addresses, only with JavaScript";
    license = licenses.mit;
    homepage = "https://email-obfuscater.lennis.dev/";
  };
}
