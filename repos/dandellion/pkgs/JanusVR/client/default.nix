{ mkDerivation, lib, fetchFromGitHub, bullet, libopus, qtbase, qt5, mesa_glu, vlc, openal, assimp, pkgconfig, tree, git, git-lfs, libxcb }:

mkDerivation {
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
 #   libxcb
  ];

  nativeBuildInputs = [
 #   pkgconfig
    git
    git-lfs
  ];


  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${bullet}/include/bullet"
    export BUILD_DIR="dist/linux/"

    #qmake FireBox.pro -spec linux-g++ CONFIG+=release CONFIG+=force_debug_info

    touch riftid.txt
  '';

#  buildPhase = ''
#    make
#  '';

  postBuild = ''
    find . -name "*openvr*"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -v janusvr $out/bin
    cp -v dependencies/linux/libopenvr_api.so $out/lib
  '';
  
  meta = with lib; {
    description = "VR Social app like the web";
    broken = false;
  };

}
