{ lib, stdenv, fetchFromGitHub, unstableGitUpdater }:

stdenv.mkDerivation rec {
  name = "iosevka-serif";

  src = fetchFromGitHub {
    owner = "devins2518";
    repo = "iosevka-serif";
    rev = "270e7139d719aa52e525697f36b03fe10ef90722";
    sha256 = "sha256-stkjtxHsM3lTKzvavFMoH38ZSGpWnBnd23gspnMJhm8=";
  };

  passthru.updateScript =
    unstableGitUpdater { url = "https://github.com/devins2518/iosevka-serif.git"; };

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
