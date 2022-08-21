{ lib
, mkDerivation
, fetchbzr
, qmake
, qtbase
, qtsvg
, cmake
, pkg-config
, poppler
, djvulibre
, libspectre
, cups
, file
, ghostscript
, wrapQtAppsHook
}:
mkDerivation rec {
  pname = "qpdfview";
  version = "0.4.99";

  src = fetchbzr {
    url = "https://code.launchpad.net/~adamreichold/qpdfview/trunk";
    rev = "2143";
    sha256 = "sha256-q27FP9D6CsUPjxwgqH2/F4oGRytUbtJgRH0ih9oaEb8=";
  };

  nativeBuildInputs = [ qmake wrapQtAppsHook pkg-config ];
  buildInputs = [
    qtbase
    qtsvg
    poppler
    djvulibre
    libspectre
    cups
    file
    ghostscript
  ];
  preConfigure = ''
    qmakeFlags+=(*.pro)
  '';

  qmakeFlags = [
    "TARGET_INSTALL_PATH=${placeholder "out"}/bin"
    "PLUGIN_INSTALL_PATH=${placeholder "out"}/lib/qpdfview"
    "DATA_INSTALL_PATH=${placeholder "out"}/share/qpdfview"
    "MANUAL_INSTALL_PATH=${placeholder "out"}/share/man/man1"
    "ICON_INSTALL_PATH=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "LAUNCHER_INSTALL_PATH=${placeholder "out"}/share/applications"
    "APPDATA_INSTALL_PATH=${placeholder "out"}/share/appdata"
  ];

  meta = with lib; {
    description = "A tabbed document viewer";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
    homepage = "https://launchpad.net/qpdfview";
  };
}

