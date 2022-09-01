{ lib, stdenv, fetchFromGitHub, qmake, qtserialport, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "visualgps-unstable";
  version = "2020-03-29";

  src = fetchFromGitHub {
    owner = "VisualGPS";
    repo = "VisualGPSqt";
    rev = "f2e213208a48e1f7d7294bc832a848de4efb4fd4";
    hash = "sha256-1x9V75Y2QgMw3oTERHiFopFxFyWRJhGKaDK/raPqxjg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qmake wrapQtAppsHook ];

  buildInputs = [ qtserialport ];

  qmakeFlags = [ "Software/VisualGPSqt/Source/VisualGPSqt.pro" ];

  postInstall =
    if stdenv.isDarwin then ''
      mkdir -p $out/Applications
      mv *.app $out/Applications
    '' else ''
      install -Dm755 VisualGPSqt -t $out/bin
    '';

  meta = with lib; {
    description = "A QT application (GUI) that makes use of the VisualGPS/NMEAParser project";
    homepage = "http://visualgps.net/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
