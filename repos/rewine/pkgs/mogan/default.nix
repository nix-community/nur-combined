{ lib
, stdenv
, fetchFromGitHub
, guile_1_8, qtbase, xmodmap, which, freetype,
  libjpeg,
  sqlite,
  aspell,
  git,
  python3
, pkg-config
, cmake
, xmake
, wrapQtAppsHook
, unzip
, curl
, zlib
, bzip2
, libpng
, brotli
, libiconv
, pdfhummus
, qtsvg
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
  ];

  nativeBuildInputs = [
    xmake
    pkg-config
    cmake
    wrapQtAppsHook
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    sqlite
    git

    unzip

    ## yes
    freetype
    zlib
    bzip2
    libpng
    libjpeg
    brotli

    libiconv
    pdfhummus
    qtbase
    qtsvg

    curl
  ];

  #installFlags = [ "prefix=${placeholder "out"}" ];
  buildPhase = ''
    export HOME=$PWD
    xmake g --network=private
    #xmake f
    xmake build --yes --verbose --diagnosis --all
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev qtsvg}/include/QtSvg"
    "-I${pdfhummus}/include/LibAesgm"
    "-L${pdfhummus}/lib"
    "-lLibAesgm.a"
  ];

  meta = with lib; {
    description = "A structure editor delivered by Xmacs Labs";
    homepage    = "https://mogan.app";
    license     = licenses.gpl3Plus;
    platforms   = platforms.all;
    maintainers = with maintainers; [ rewine ];
  };
}
