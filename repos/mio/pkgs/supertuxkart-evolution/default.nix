{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchsvn,
  cmake,
  pkg-config,
  makeWrapper,
  SDL2,
  glew,
  openal,
  libvorbis,
  libogg,
  curl,
  freetype,
  libjpeg,
  libpng,
  libX11,
  harfbuzz,
  mcpp,
  wiiuse,
  angelscript,
  libopenglrecorder,
  sqlite,
  libsamplerate,
  shaderc,
}:
let
  assets = fetchsvn {
    url = "https://svn.code.sf.net/p/supertuxkart/code/media/trunk";
    rev = "18626";
    sha256 = "sha256-Ka3Ft9apQIGk0I/2DTuZ278W0xOkfumCeqthGpCJYds=";
    name = "stk-assets";
  };

  # List of bundled libraries in stk-code/lib to keep
  bundledLibraries = [
    "bullet"
    "enet"
    "graphics_engine"
    "graphics_utils"
    "simd_wrapper"
    "irrlicht"
    "libsquish"
    "sheenbidi"
    "tinygettext"
    "mojoal"
  ];
in
stdenv.mkDerivation rec {

  pname = "supertuxkart-evolution";
  version = "1.5-evolution-2025-12-05";

  src = fetchFromGitHub {
    owner = "supertuxkart";
    repo = "stk-code";
    # BalanceSTK2 branch commit
    rev = "26ebd89a985a8bcd41da7cd005524ea1a180ba42";
    sha256 = "0s8bc8fkgr9bgrykkwfrxrpa26bq9751d0vdy2x2hfpz8h78mrpv";
  };

  postPatch = ''
    # Deletes all bundled libs in stk-code/lib except those
    # That couldn't be replaced with system packages
    find lib -maxdepth 1 -type d | egrep -v "^lib$|${(lib.concatStringsSep "|" bundledLibraries)}" | xargs -n1 -L1 -r -I{} rm -rf {}

    # Allow building with system-installed wiiuse on Darwin
    substituteInPlace CMakeLists.txt \
      --replace 'NOT (APPLE OR HAIKU)) AND USE_SYSTEM_WIIUSE' 'NOT (HAIKU)) AND USE_SYSTEM_WIIUSE'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    shaderc
    SDL2
    glew
    libvorbis
    libogg
    freetype
    curl
    libjpeg
    libpng
    libX11
    harfbuzz
    mcpp
    wiiuse
    angelscript
    sqlite
  ]
  ++ lib.optional (stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isLinux) libopenglrecorder
  ++ lib.optional stdenv.hostPlatform.isLinux openal
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libsamplerate
  ];

  cmakeFlags = [
    "-DBUILD_RECORDER=${
      if (stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isLinux) then "ON" else "OFF"
    }"
    "-DUSE_SYSTEM_ANGELSCRIPT=ON"
    "-DCHECK_ASSETS=OFF"
    "-DUSE_SYSTEM_WIIUSE=ON"
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  # NIX_CFLAGS_COMPILE = [ "-I${SDL2.dev}/include/SDL2" ]; # Maybe needed?

  CXXFLAGS = [
    "-include cstdio"
    "-include stdexcept"
  ];

  postInstall = ''
    # Rename binary
    if [ -f $out/bin/supertuxkart ]; then
      mv $out/bin/supertuxkart $out/bin/supertuxkart-evolution
    fi

    # Handle desktop file
    if [ -d $out/share/applications ]; then
      mv $out/share/applications/supertuxkart.desktop $out/share/applications/supertuxkart-evolution.desktop
      substituteInPlace $out/share/applications/supertuxkart-evolution.desktop \
        --replace-fail "Exec=supertuxkart" "Exec=supertuxkart-evolution" \
        --replace-fail "Name=SuperTuxKart" "Name=SuperTuxKart Evolution"
    fi

    # Handle macOS .app
    if [ -d $out/supertuxkart.app ]; then
      mv $out/supertuxkart.app $out/SuperTuxKart-Evolution.app
    fi
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    if [ -d $out/SuperTuxKart-Evolution.app ]; then
      mv $out/SuperTuxKart-Evolution.app/Contents/MacOS/supertuxkart $out/bin/supertuxkart-evolution
      rm -rf $out/SuperTuxKart-Evolution.app
    fi
  '';

  preFixup = ''
    wrapProgram $out/bin/supertuxkart-evolution \
      --set-default SUPERTUXKART_ASSETS_DIR "${assets}" \
      --set-default SUPERTUXKART_DATADIR "$out/share/supertuxkart" \
  '';

  meta = {
    description = "3D open-source arcade racer (Evolution branch)";
    mainProgram = "supertuxkart-evolution";
    homepage = "https://supertuxkart.net/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
