{ lib
, stdenv
, fetchFromGitHub
, cmake
, desktopToDarwinBundle
, wrapQtAppsHook
, qtsvg
, qtwebsockets
, qtx11extras
, mosquitto
, libdwarf
, protobuf
, zeromq
, zstd
}:

stdenv.mkDerivation rec {
  pname = "plotjuggler";
  version = "3.8.8";

  src = fetchFromGitHub {
    owner = "facontidavide";
    repo = "PlotJuggler";
    rev = version;
    hash = "sha256-xJ3MEDXZ+nRHNFEuXXeFb6Ed7fKTXtHZg1rH2tEgviQ=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(PJ_PLUGIN_INSTALL_DIRECTORY bin)" "set(PJ_PLUGIN_INSTALL_DIRECTORY lib/plugins)"
    substituteInPlace plotjuggler_app/mainwindow.cpp \
      --replace "QCoreApplication::applicationDirPath()" "\"$out/lib/plugins\""
  '';

  nativeBuildInputs = [ cmake wrapQtAppsHook ]
    ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [ qtsvg qtwebsockets mosquitto libdwarf protobuf zeromq zstd ]
    ++ lib.optionals stdenv.isLinux [ qtx11extras ];

  meta = with lib; {
    description = "The Time Series Visualization Tool";
    homepage = "https://www.plotjuggler.io/";
    license = licenses.mpl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # _AbslInternalSpinLockWake_lts_20230125 not found
  };
}
