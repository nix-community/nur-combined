{ lib, stdenv, fetchFromGitHub, unstableGitUpdater }:

stdenv.mkDerivation rec {
  name = "iosevka-serif";

  src = fetchFromGitHub {
    owner = "devins2518";
    repo = "iosevka-serif";
    rev = "04d1b83227e9f7eb2ffb590c6cff14a0b88a6481";
    sha256 = "sha256-kszJoKQLITYMfISzANm9bYoWsDdSt/z+RVYHTzs94Vw=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts
    install out/*.ttf $out/share/fonts
    install norm/*.ttf $out/share/fonts
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/devins2518/iosevka-serif";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ devins2518 ];
  };
}
