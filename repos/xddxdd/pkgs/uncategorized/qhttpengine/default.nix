{
  stdenv,
  sources,
  lib,
  cmake,
  qt5,
}:
stdenv.mkDerivation rec {
  inherit (sources.qhttpengine) pname version src;

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ qt5.qtbase ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "HTTP server for Qt applications";
    homepage = "https://github.com/nitroshare/qhttpengine";
    license = lib.licenses.mit;
  };
}
