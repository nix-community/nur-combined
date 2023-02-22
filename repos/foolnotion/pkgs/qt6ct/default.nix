{ lib
, fetchFromGitHub
, qmake
, qtbase
, qtsvg
, qttools
, qtwayland
, cmake
, pkg-config
, wrapQtAppsHook
, stdenv
}:
stdenv.mkDerivation rec {
  pname = "qt6ct";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "trialuser02";
    repo = "qt6ct";
    rev = version;
    sha256 = "sha256-7WuHdb7gmdC/YqrPDT7OYbD6BEm++EcIkmORW7cSPDE=";
  };

  nativeBuildInputs = [qmake qttools qtwayland wrapQtAppsHook];

  buildInputs = [qtbase qtsvg];

  qmakeFlags = [
    "LRELEASE_EXECUTABLE=${lib.getDev qttools}/bin/lrelease"
    "PLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Qt6 Configuration Tool";
    license = licenses.bsd2;
    #maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
    homepage = "https://github.com/trialuser02/qt6ct";
  };
}

