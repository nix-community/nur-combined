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
stdenv.mkDerivation (_finalAttrs: {
  pname = "gepetto-viewer";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "gepetto";
    repo = "gepetto-viewer";
    #rev = "v${finalAttrs.version}";
    rev = "c10ea01";
    hash = "sha256-VPUcdhTXc9LqKauElzsMG/YHDDyjujYLJ07yeoue9C4=";
  };

  cmakeFlags = [ "-DBUILD_PY_QCUSTOM_PLOT=ON" ];

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
