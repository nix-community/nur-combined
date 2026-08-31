{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  qt6,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qtwebapp";
  version = "1.9.1";
  src = fetchFromGitHub {
    owner = "fffaraz";
    repo = "QtWebApp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RbFgz2ed1eEVy44LX+milP4hPSeiabakU3TMvHYR7TU=";
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

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "HTTP server library in C++, inspired by Java Servlets";
    homepage = "https://stefanfrings.de/qtwebapp/index-en.html";
    changelog = "https://stefanfrings.de/qtwebapp/index-en.html";
    license = lib.licenses.lgpl3Plus;
  };
})
