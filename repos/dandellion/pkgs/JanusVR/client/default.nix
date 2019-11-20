{ stdenv, fetchFromGitHub, bullet, libopus, qt5, mesa_glu, vlc, openal, assimp, pkgconfig, tree }:

stdenv.mkDerivation {
  pname = "janus";
  version = "66.4";
  
  src = fetchFromGitHub {
    owner = "janusvr";
    repo = "janus";
    rev = "ed2c4686e9f255f3381d9876886ed73040e85897";
    sha256 = "0x0p1i5mzv5b5krj9zick7yb2iiylvj0p3syq6d7yf23yyxnaxxb";
  };

  buildInputs = [
    tree
    mesa_glu
    vlc
    qt5.qmake
    qt5.qtwebsockets
    qt5.qtwebengine
    qt5.qtscript
    bullet
    libopus
    openal
    assimp
  ];

  nativeBuildInputs = [
    pkgconfig
  ];


  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${bullet}/include/bullet"
  '';

  BuildPhase = ''
    tree .
  '';
  
  meta = {
    description = "VR Social app like the web";
    broken = false;
  };

}
