{ lib, fetchFromGitHub, qt5, }:
qt5.mkDerivation rec {
  pname = "dragger";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ambroisie";
    repo = "dragger";
    rev = "v${version}";
    hash = "sha256-WAC720DxfkQxy1BeeGzE6IerFb4ejoMRAPEJv5HGDHM=";
  };

  configurePhase = ''
    qmake
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp dragger $out/bin
  '';

  meta = with lib; {
    description = "A CLI drag-and-drop tool";
    homepage = "https://git.belanyi.fr/ambroisie/dragger";
    license = licenses.mit;
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.linux;
  };
}
