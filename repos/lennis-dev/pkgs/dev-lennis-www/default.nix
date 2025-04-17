{ stdenv, fetchgit, lib }:

stdenv.mkDerivation rec {
  name = "dev-lennis-www-${version}";
  version = "df2b3c0";
  src = fetchgit {
    url = "https://github.com/lennis-dev/lennis.dev.git";
    rev = "df2b3c08d4d4daf0a6c273694ee6ccdd78679a71";
    hash = "sha256-A9pdQTy9Qb791Wt7Pf+DL7PHqRzy0THOy1Lz+7H6Ao0=";
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
