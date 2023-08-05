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
, nowide
, boost
}:

stdenv.mkDerivation rec {
  pname = "mogan";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "XmacsLabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RtXWIhAu8QvWtzqZP5c4m/zSrW3a7r9nVL7qVrDQqxc=";
  };

  patches = [
    ./use-system-lib.patch
  ];

  nativeBuildInputs = [
    xmake
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    # make xmake happly
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
    #nowide
    #boost
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    xmake g --network=private
    #xmake f
    xmake build --yes --verbose --diagnosis --all -j $NIX_BUILD_CORES 
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev qtsvg}/include/QtSvg"
    "-L${pdfhummus}/lib"
    "-lLibAesgm"
    "-lPDFWriter"
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
