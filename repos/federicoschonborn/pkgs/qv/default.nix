{ lib
, stdenv
, fetchzip
, cmake
, ninja
, wrapQtAppsHook
, libtgd
, qtbase
, qtwayland
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qv";
  version = "5.1";

  src = fetchzip {
    url = "https://marlam.de/qv/releases/qv-${finalAttrs.version}.tar.gz";
    hash = "sha256-zrpbpifk0cPbdaXfX7I75BFOuTLaoj59lx0aXKOoU8g=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    libtgd
    qtbase
  ] ++ lib.optionals (!stdenv.isDarwin) [ qtwayland ];

  meta = with lib; {
    description = "A a viewer for 2D data such as images, sensor data, simulations, renderings and videos";
    homepage = "https://marlam.de/qv/";
    downloadPage = "https://marlam.de/qv/download/";
    license = licenses.mit;
    # Broken by libtgd
    broken = stdenv.isDarwin;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
