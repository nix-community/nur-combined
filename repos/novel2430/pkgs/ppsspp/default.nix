{
  lib,
  SDL2,
  cmake,
  copyDesktopItems,
  fetchFromGitHub,
  ffmpeg_6,
  glew,
  libffi,
  libsForQt5,
  libzip,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  python3,
  snappy,
  stdenv,
  vulkan-loader,
  wayland,
  zlib,
}:

let
  inherit (libsForQt5) qtbase qtmultimedia wrapQtAppsHook;
in
stdenv.mkDerivation rec {
  pname = "ppsspp";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "hrydgard";
    repo = "ppsspp";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-X5Sb6oxjjhlsm1VN9e0Emk4SqiHTe3G3ZiuIgw5DSds=";
  };

  postPatch = ''
    substituteInPlace git-version.cmake --replace-warn unknown ${src.rev}
    substituteInPlace UI/NativeApp.cpp --replace-fail /usr/share $out/share
  '';

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    python3
    wrapQtAppsHook
  ];

  buildInputs = [
    SDL2
    glew
    libzip
    zlib
    ffmpeg_6
    snappy
    qtbase
    vulkan-loader
    wayland
    libffi
    qtmultimedia
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_FFMPEG" false)
    (lib.cmakeBool "USE_SYSTEM_LIBZIP" true)
    (lib.cmakeBool "USE_SYSTEM_SNAPPY" true)
    (lib.cmakeBool "USE_WAYLAND_WSI" true)
    (lib.cmakeBool "USING_QT_UI" true)
    (lib.cmakeFeature "OpenGL_GL_PREFERENCE" "GLVND")
  ];

  desktopItems = [
    (makeDesktopItem {
      desktopName = "PPSSPP";
      name = "ppsspp";
      exec = "ppsspp";
      icon = "ppsspp";
      comment = "ppsspp (fast and portable PSP emulator)";
      categories = [ "Game" "Emulator" ];
      keywords = ["Sony" "PlayStation" "Portable" "PSP" "handheld" "console"];
    })
  ];

  installPhase =''
    runHook preInstall
    mkdir -p $out/share/icons
    mkdir -p $out/share/ppsspp
    mkdir -p $out/bin
    # Install assets
    mv assets $out/share/ppsspp/assets
    # Install Binary
    install -Dm555 PPSSPPQt $out/share/ppsspp/PPSSPP
    # Install Icons
    for res in 16 24 32 48 64 96 128 256 512; do
        install -Dm644 \
            ../icons/hicolor/''${res}x''${res}/apps/ppsspp.png \
            $out/share/icons/hicolor/''${res}x''${res}/apps/PPSSPP.png
    done
    # Wrapping QT
    wrapQtApp $out/share/ppsspp/PPSSPP
    # MakeWrapper
    makeWrapper $out/share/ppsspp/PPSSPP $out/bin/ppsspp \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}
    runHook postInstall
  '';

  postFixup = ''

  '';

  meta = {
    homepage = "https://www.ppsspp.org/";
    description = "HLE Playstation Portable emulator, written in C++ (QT)";
    longDescription = ''
      PPSSPP is a PSP emulator, which means that it can run games and other
      software that was originally made for the Sony PSP.

      The PSP had multiple types of software. The two most common are native PSP
      games on UMD discs and downloadable games (that were stored in the
      directory PSP/GAME on the "memory stick"). But there were also UMD Video
      discs, and PS1 games that could run in a proprietary emulator. PPSSPP does
      not run those.
    '';
    license = lib.licenses.gpl2Plus;
    mainProgram = "ppsspp";
    platforms = [ "x86_64-linux" ];
  };
}
