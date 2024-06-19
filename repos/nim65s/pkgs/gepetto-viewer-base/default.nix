{
  stdenv,
  fetchFromGitHub,
  lib,
  boost,
  cmake,
  doxygen,
  jrl-cmakemodules,
  openscenegraph,
  osgqt,
  pkg-config,
  python3Packages,
  qgv,
  libsForQt5,
  python-qt,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gepetto-viewer";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = "gepetto-viewer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e+MYEJA98U+ZUv2Aza/S7CGbQSJht7xFtmx229HmlOs=";
  };

  outputs = [
    "out"
    "doc"
  ];

  buildInputs = [
    boost
    python-qt
    libsForQt5.qtbase
    osgqt
    python3Packages.boost
    python3Packages.python
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];

  propagatedBuildInputs = [
    jrl-cmakemodules
    openscenegraph
    osgqt
    qgv
  ];

  doCheck = true;

  # display a black screen on wayland, so force XWayland for now.
  # Might be fixed when upstream will be ready for Qt6.
  qtWrapperArgs = [ "--set QT_QPA_PLATFORM xcb" ];

  meta = {
    homepage = "https://github.com/gepetto/gepetto-viewer";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.nim65s ];
    mainProgram = "gepetto-gui";
  };
})
