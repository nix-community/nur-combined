{ lib
, fetchbzr
, qmake
, qtbase
, qtsvg
, qtwayland
, cmake
, pkg-config
, poppler
, djvulibre
, libspectre
, cups
, file
, ghostscript
, wrapQtAppsHook
, stdenv
}:
stdenv.mkDerivation rec {
  pname = "qpdfview";
  version = "0.5.0";

  src = fetchbzr {
    url = "https://code.launchpad.net/~adamreichold/qpdfview/trunk";
    rev = "2152";
    sha256 = "sha256-huYAyT12U7a3RgRu3W4McYnhFYEvKCmKb59E9vOSXsE=";
  };

  nativeBuildInputs = [ qmake wrapQtAppsHook pkg-config ];
  buildInputs = [
    qtbase
    qtsvg
    qtwayland
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

  env = {
    # Fix build due to missing `std::option`.
    NIX_CFLAGS_COMPILE = "-std=c++17";
  };


  meta = with lib; {
    description = "A tabbed document viewer";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
    homepage = "https://launchpad.net/qpdfview";
  };
}

