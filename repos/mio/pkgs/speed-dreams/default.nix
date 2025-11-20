{
  fetchurl,
  lib,
  stdenv,
  libGLU,
  libGL,
  libglut,
  libX11,
  plib,
  openal,
  freealut,
  libXrandr,
  xorgproto,
  libXext,
  libSM,
  libICE,
  libXi,
  libXt,
  libXrender,
  libXxf86vm,
  openscenegraph,
  expat,
  libpng,
  zlib,
  bash,
  SDL2,
  SDL2_mixer,
  enet,
  libjpeg,
  cmake,
  pkg-config,
  libvorbis,
  runtimeShell,
  curl,
  fetchgit,
  cjson,
  minizip,
  rhash,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  version = "2.4.2";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "speed-dreams";

  src = fetchgit {
    url = "https://forge.a-lec.org/speed-dreams/speed-dreams-code.git";
    rev = "v${version}";
    sha256 = "sha256-ZY/0tf0wFbepEUNqpaBA4qgkWDij/joqPtbiF/48oN4=";
    fetchSubmodules = true;
  };
  NIX_CFLAGS_COMPILE = "-I${src}/src/libs/tgf -I${src}/src/libs/tgfdata -I${src}/src/interfaces -I${src}/src/libs/math -I${src}/src/libs/portability";

  postInstall = ''
    mkdir -p "$out/bin"
    # Wrapper for main executable
    cat > "$out/bin/speed-dreams" <<EOF
    #!${runtimeShell}
    export LD_LIBRARY_PATH="$out/lib/games/speed-dreams-2/lib:$out/lib"
    exec "$out/games/speed-dreams-2" "$@"
    EOF
    chmod a+x "$out/bin/speed-dreams"

    # Symlink for desktop icon
    mkdir -p $out/share/pixmaps/
    ln -s "$out/share/games/speed-dreams-2/data/icons/icon.png" "$out/share/pixmaps/speed-dreams-2.png"
  '';

  # RPATH of binary /nix/store/.../lib64/games/speed-dreams-2/drivers/shadow_sc/shadow_sc.so contains a forbidden reference to /build/
  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    copyDesktopItems
  ];

  buildInputs = [
    libpng
    libGLU
    libGL
    libglut
    libX11
    plib
    openal
    freealut
    libXrandr
    xorgproto
    libXext
    libSM
    libICE
    libXi
    libXt
    libXrender
    libXxf86vm
    zlib
    bash
    expat
    SDL2
    SDL2_mixer
    enet
    libjpeg
    openscenegraph
    libvorbis
    curl
    cjson
    minizip
    rhash
  ];

  meta = {
    description = "Car racing game - TORCS fork with more experimental approach";
    homepage = "https://www.speed-dreams.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    hydraPlatforms = [ ];
  };
}
