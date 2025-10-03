{
  stdenv,
  lib,
  fetchzip,
  qt6,
  ...
}:
stdenv.mkDerivation {
  pname = "qtwebapp";
  version = "1.9.1";
  src = fetchzip {
    url = "https://stefanfrings.de/qtwebapp/QtWebApp.zip";
    hash = "sha256-UzF/+5eXJGERf9V4uWVRl/EN1uY/zWVTTCdkhdVc7YE=";
  };
  sourceRoot = "source/QtWebApp";

  postPatch = ''
    cat >>QtWebApp.pro <<EOF
    unix {
      target.path += $out/lib
      INSTALLS += target
    }
    EOF
  '';

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qt5compat
  ];

  qmakeFlags = [ "QtWebApp.pro" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "HTTP server library in C++, inspired by Java Servlets";
    homepage = "https://stefanfrings.de/qtwebapp/index-en.html";
    license = lib.licenses.lgpl3Plus;
  };
}
