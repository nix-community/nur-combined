{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
}:

stdenv.mkDerivation {
  pname = "visualgps";
  version = "1.0-unstable-2020-03-29";

  src = fetchFromGitHub {
    owner = "VisualGPS";
    repo = "VisualGPSqt";
    rev = "f2e213208a48e1f7d7294bc832a848de4efb4fd4";
    hash = "sha256-1x9V75Y2QgMw3oTERHiFopFxFyWRJhGKaDK/raPqxjg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ qt5.qtserialport ];

  qmakeFlags = [ "Software/VisualGPSqt/Source/VisualGPSqt.pro" ];

  postInstall =
    if stdenv.isDarwin then
      ''
        mkdir -p $out/Applications
        mv *.app $out/Applications
      ''
    else
      ''
        install -Dm755 VisualGPSqt -t $out/bin
      '';

  meta = {
    description = "A QT application (GUI) that makes use of the VisualGPS/NMEAParser project";
    homepage = "http://visualgps.net/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
