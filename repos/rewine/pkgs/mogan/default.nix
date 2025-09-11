{ lib
, stdenv
, fetchFromGitHub
, substituteAll
, xmake
, cmake
, pkg-config
, wrapQtAppsHook
, qtbase
, qtsvg
, curl
, freetype
, zlib
, bzip2
, libpng
, libjpeg
, brotli
, libiconv
, pdfhummus
, git
, unzip
, ghostscript
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
    (substituteAll {
      src = ./patch-ghostscript-path.diff;
      inherit ghostscript;
      ghostscriptVersion = ghostscript.version;
    })
  ];

  postPatch = ''
    substituteInPlace src/Plugins/Freetype/free_type.cpp \
      --replace "/usr/lib/libfreetype" "${freetype}/lib/libfreetype"
  '';

  nativeBuildInputs = [
    xmake
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    qtbase
    curl
    qtsvg
    freetype
    zlib
    bzip2
    libpng
    libjpeg
    brotli
    libiconv
    pdfhummus
    # make xmake happly
    git
    unzip
  ];

  configurePhase = ''
    runHook preConfigure
    export HOME=$(mktemp -d)
    xmake global --network=private
    xmake config -m release --verbose --yes --diagnosis
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    xmake build --yes --verbose --all -j $NIX_BUILD_CORES 
    runHook postBuild
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev qtsvg}/include/QtSvg"
    #"-L${pdfhummus}/lib"
    "-lLibAesgm" "-lPDFWriter"
  ];

  installPhase = ''
    runHook preInstall
    xmake install -o $out mogan_install
    runHook postInstall
  '';

  meta = {
    description = "A structure editor delivered by Xmacs Labs";
    homepage    = "https://mogan.app";
    license     = lib.licenses.gpl3Plus;
    platforms   = lib.platforms.all;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
