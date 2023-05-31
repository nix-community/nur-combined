{ lib
, stdenv
, fetchFromGitHub
, xmake
, cmake
, pkg-config
, wrapQtAppsHook
, git
, unzip
, curl
, qtbase
, qtsvg
, freetype
, zlib
, bzip2
, libpng
, libjpeg
, brotli
, libiconv
, pdfhummus
}:

stdenv.mkDerivation rec {
  pname = "mogan";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "XmacsLabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7QxcQT5THbVouRsTzte6h7vTnGvldHiOJQiiwSC06us=";
  };

  patches = [
    ./use-system-lib.patch
    ./fix-build.patch
  ];

  nativeBuildInputs = [
    xmake
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    git
    unzip
    curl

    qtbase
    qtsvg
    freetype
    zlib
    bzip2
    libpng
    libjpeg
    brotli
    libiconv
    pdfhummus
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    xmake g --network=private
    #xmake f
    xmake build --yes --verbose --diagnosis --all
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev qtsvg}/include/QtSvg"
  ];

  installPhase = ''
    xmake install -o $out
  '';

  meta = with lib; {
    description = "A structure editor delivered by Xmacs Labs";
    homepage    = "https://mogan.app";
    license     = licenses.gpl3Plus;
    platforms   = platforms.all;
    maintainers = with maintainers; [ rewine ];
  };
}
