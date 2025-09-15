{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-email-obfuscater-${version}";
  version = "8984185";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "email-obfuscater";
    rev = "898418542d9ab7484c26666d0843d424205b315e";
    hash = "sha256-N07WX2NO2zg2UT/pDlYpDKrcQmHzSa0liE4G6JH2mzc=";
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
