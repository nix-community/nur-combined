{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, callPackage
, pkg-config
, cmake
, ninja
, clang
, python3
, wrapQtAppsHook
, removeReferencesTo
, qtbase
, qtimageformats
, qtsvg
, qtwayland
, qt5compat
, lz4
, xxHash
, ffmpeg_4
, openalSoft
, minizip
, libopus
, alsa-lib
, libpulseaudio
, range-v3
, tl-expected
, hunspell
, glibmm
, jemalloc
, rnnoise
, abseil-cpp
, microsoft_gsl
, wayland
, libicns
, Cocoa
, CoreFoundation
, CoreServices
, CoreText
, CoreGraphics
, CoreMedia
, OpenGL
, AudioUnit
, ApplicationServices
, Foundation
, AGL
, Security
, SystemConfiguration
, Carbon
, AudioToolbox
, VideoToolbox
, VideoDecodeAcceleration
, AVFoundation
, CoreAudio
, CoreVideo
, CoreMediaIO
, QuartzCore
, AppKit
, CoreWLAN
, WebKit
, IOKit
, GSS
, MediaPlayer
, IOSurface
, Metal
, MetalKit
}:

with lib;

let
  tg_owt = callPackage ./tg_owt.nix {
    abseil-cpp = abseil-cpp.override {
      # abseil-cpp should use the same compiler
      inherit stdenv;
      cxxStandard = "20";
    };

    # tg_owt should use the same compiler
    inherit stdenv;

    inherit Cocoa AppKit IOKit IOSurface Foundation AVFoundation CoreMedia VideoToolbox
      CoreGraphics CoreVideo OpenGL Metal MetalKit CoreFoundation ApplicationServices;
  };

  tgcallsPatch = fetchpatch {
    url = "https://github.com/TelegramMessenger/tgcalls/commit/82c4921045c440b727c38e464f3a0539708423ff.patch";
    sha256 = "sha256-FIPelc6QQsQi9JYHaxjt87lE0foCYd7BNPrirUDp6VM=";
  };

  mainProgram = if stdenv.isLinux then "kotatogram-desktop" else "Kotatogram";
in
stdenv.mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "unstable-2023-06-16";

  src = fetchFromGitHub {
    owner = "ilya-fedin";
    repo = "kotatogram-desktop";
    rev = "bd1a4802ea227d0d3aa156a6d445ed51bc93afed";
    sha256 = "sha256-AyBKOf+74tGVnBJbQHa3TRGGLe1fQIlGGdDLJrI3HTE=";
    fetchSubmodules = true;
  };

  patches = [
    ./shortcuts-binary-path.patch
  ];

  postPatch = ''
    patch -p1 -d Telegram/ThirdParty/tgcalls < ${tgcallsPatch}
  '' + optionalString stdenv.isLinux ''
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace '"libpulse.so.0"' '"${libpulseaudio}/lib/libpulse.so.0"'
  '' + optionalString stdenv.isDarwin ''
    sed -i "13i#import <CoreAudio/CoreAudio.h>" Telegram/lib_webrtc/webrtc/mac/webrtc_media_devices_mac.mm
    substituteInPlace Telegram/CMakeLists.txt \
      --replace 'COMMAND iconutil' 'COMMAND png2icns' \
      --replace '--convert icns' "" \
      --replace '--output AppIcon.icns' 'AppIcon.icns' \
      --replace "\''${appicon_path}" "\''${appicon_path}/icon_16x16.png \''${appicon_path}/icon_32x32.png \''${appicon_path}/icon_128x128.png \''${appicon_path}/icon_256x256.png \''${appicon_path}/icon_512x512.png"
  '';

  # Wrapping the inside of the app bundles, avoiding double-wrapping
  dontWrapQtApps = stdenv.isDarwin;

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    wrapQtAppsHook
    removeReferencesTo
  ] ++ optionals stdenv.isLinux [
    # to build bundled libdispatch
    clang
  ];

  buildInputs = [
    qtbase
    qtimageformats
    qtsvg
    qt5compat
    lz4
    xxHash
    ffmpeg_4
    openalSoft
    minizip
    libopus
    range-v3
    tl-expected
    rnnoise
    tg_owt
    microsoft_gsl
  ] ++ optionals stdenv.isLinux [
    qtwayland
    alsa-lib
    libpulseaudio
    hunspell
    glibmm
    jemalloc
    wayland
  ] ++ optionals stdenv.isDarwin [
    Cocoa
    CoreFoundation
    CoreServices
    CoreText
    CoreGraphics
    CoreMedia
    OpenGL
    AudioUnit
    ApplicationServices
    Foundation
    AGL
    Security
    SystemConfiguration
    Carbon
    AudioToolbox
    VideoToolbox
    VideoDecodeAcceleration
    AVFoundation
    CoreAudio
    CoreVideo
    CoreMediaIO
    QuartzCore
    AppKit
    CoreWLAN
    WebKit
    IOKit
    GSS
    MediaPlayer
    IOSurface
    Metal
    libicns
  ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DTDESKTOP_API_TEST=ON"
  ];

  installPhase = optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r ${mainProgram}.app $out/Applications
    ln -s $out/{Applications/${mainProgram}.app/Contents/MacOS,bin}
  '';

  preFixup = ''
    remove-references-to -t ${stdenv.cc.cc} $out/bin/${mainProgram}
    remove-references-to -t ${microsoft_gsl} $out/bin/${mainProgram}
    remove-references-to -t ${tg_owt.dev} $out/bin/${mainProgram}
  '';

  postFixup = optionalString stdenv.isDarwin ''
    wrapQtApp $out/Applications/${mainProgram}.app/Contents/MacOS/${mainProgram}
  '';

  passthru = {
    inherit tg_owt;
  };

  meta = {
    inherit mainProgram;
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.

      It contains some useful (or purely cosmetic) features, but they could be unstable. A detailed list is available here: https://kotatogram.github.io/changes
    '';
    license = licenses.gpl3;
    platforms = platforms.all;
    homepage = "https://kotatogram.github.io";
    changelog = "https://github.com/kotatogram/kotatogram-desktop/releases/tag/k{version}";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
