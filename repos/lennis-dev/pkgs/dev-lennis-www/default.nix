{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation rec {
  name = "dev-lennis-www-${version}";
  version = "772ad14";
  src = fetchFromGitHub {
    owner = "lennis-dev";
    repo = "lennis.dev";
    rev = "772ad145334b4a03cef3fadccf9ccbe048f99208";
    hash = "sha256-ShxPtE5xED/PU2lV3EDznX3Lmi33Ge0m2+kukJahHoI=";
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
