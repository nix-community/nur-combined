{
  stdenv,
  fetchzip,
  cmake,
  libgta,
  libtgd,
  qtbase,
  qtwayland,
  wrapQtAppsHook,
}:
stdenv.mkDerivation rec {
  pname = "qv";
  version = "5.1";

  src = fetchzip {
    url = "https://marlam.de/qv/releases/qv-${version}.tar.gz";
    hash = "sha256-zrpbpifk0cPbdaXfX7I75BFOuTLaoj59lx0aXKOoU8g=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    libgta
    libtgd
    qtbase
    qtwayland
  ];
}
