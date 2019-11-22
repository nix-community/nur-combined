{ mkDerivation, lib, fetchFromGitHub, 
bullet, libopus, vlc, openal, assimp, libvorbis,
qtbase, qt5, mesa_glu, tree, git, git-lfs, zlib}:

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
    libvorbis
    openal
    assimp
    zlib
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
    cp -r -v assets $out/bin/assets
  '';
  
  meta = with lib; {
    description = "VR Social app like the web";
    broken = false;
  };

}
