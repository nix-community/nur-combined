{ lib, stdenv, fetchFromGitHub, unstableGitUpdater }:

stdenv.mkDerivation rec {
  name = "iosevka-serif";

  src = fetchFromGitHub {
    owner = "devins2518";
    repo = "iosevka-serif";
    rev = "09769449724b3f053a4f29c9e4cd3e6bd9f9b042";
    sha256 = "12891hlvhwzj4yl4vq5clh26h5dhg4p6kg4lq6nhb097i04a359f";
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
