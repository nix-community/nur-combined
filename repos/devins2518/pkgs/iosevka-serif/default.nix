{ lib, stdenv, fetchFromGitHub, unstableGitUpdater }:

stdenv.mkDerivation rec {
  name = "iosevka-serif";

  src = fetchFromGitHub {
    owner = "devins2518";
    repo = "iosevka-serif";
    rev = "cc9620dcbb661662a81dc9e4d8cdbc1270312780";
    sha256 = "15zmx07dnrmjy50znnr8bl0jfsmgx17a51wjsvv0klsgyvyk00wp";
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
