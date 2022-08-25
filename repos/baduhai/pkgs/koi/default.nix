{ lib, mkDerivation, fetchFromGitHub, cmake, qtbase, wrapQtAppsHook, kcoreaddons, kwidgetsaddons, kconfig }:

mkDerivation rec{
  name = "koi";
  version = "0.2.1";
  
  src = fetchFromGitHub {
    owner = "baduhai";
    repo = "Koi";
    rev = "26b6364890afbfa3281bcc959a3c49d4609447a7";
    sha256 = "7RpPwlG5Qt8kunrbJx1Cs3pdh+sCPpdvSsv1usWMnNo=";
  };
  
  nativeBuildInputs = [ cmake ];
  
  buildInputs = [ wrapQtAppsHook kcoreaddons kwidgetsaddons kconfig ];
  
  sourceRoot = "source/src";
  
  meta = with lib; {
    description = "Theme scheduling for the KDE Plasma Desktop";
    homepage = "https://github.com/baduhai/Koi";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
