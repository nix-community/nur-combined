{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  desktopToDarwinBundle,
  qt5,
  mosquitto,
  libdwarf,
  protobuf,
  zeromq,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plotjuggler";
  version = "3.9.3";

  src = fetchFromGitHub {
    owner = "facontidavide";
    repo = "PlotJuggler";
    tag = finalAttrs.version;
    hash = "sha256-tcEcFGLLEHsBDb3sBEPs/WmDf7NNnwL/hbme5XfMgJI=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(PJ_PLUGIN_INSTALL_DIRECTORY bin)" "set(PJ_PLUGIN_INSTALL_DIRECTORY lib/plugins)"
    substituteInPlace plotjuggler_app/mainwindow.cpp \
      --replace-fail "QCoreApplication::applicationDirPath()" "\"$out/lib/plugins\""
  '';

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ]
  ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [
    qt5.qtsvg
    qt5.qtwebsockets
    mosquitto
    libdwarf
    protobuf
    zeromq
    zstd
  ]
  ++ lib.optionals stdenv.isLinux [ qt5.qtx11extras ];

  meta = {
    description = "The Time Series Visualization Tool";
    homepage = "https://www.plotjuggler.io/";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = true;
  };
})
