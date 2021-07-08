{ lib, stdenv, fetchFromGitHub, unstableGitUpdater }:

stdenv.mkDerivation rec {
  name = "iosevka-serif";

  src = fetchFromGitHub {
    owner = "devins2518";
    repo = "iosevka-serif";
    rev = "e39be4da970ef909d8788fc8ef4d6de3a47a9ee8";
    sha256 = "1kgwlccrmsvhsmvg3i21597p60n80zsh8a3yrds1615qjfmwvfa5";
  };

  installPhase = ''
    mkdir -p $out/share/fonts
    install norm/*.ttf $out/share/fonts
    install iosevka-serif-term/complete/*.ttf $out/share/fonts
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/devins2518/iosevka-serif";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ devins2518 ];
  };
}
