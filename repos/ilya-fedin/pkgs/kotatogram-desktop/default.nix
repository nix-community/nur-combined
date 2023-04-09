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
, extra-cmake-modules
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

  codegenPatch = fetchpatch {
    url = "https://github.com/desktop-app/codegen/commit/762500d143448189ee5c06239b52268ca1b6b74a.patch";
    sha256 = "sha256-Al2/Pfy9wYAtaCycsrlt5FjaFMkgTJhFKOQ/8puAJl8=";
  };

  libUiPatch = fetchpatch {
    url = "https://github.com/desktop-app/lib_ui/commit/e91cfd55c243cfd2fa0d04f58616ee4f0a0ccb11.patch";
    sha256 = "sha256-2ieOpC4RXFId1qibCeClJOP4NWdvPrq0v/fRil6/7jc=";
  };

  tgcallsPatch = fetchpatch {
    url = "https://github.com/TelegramMessenger/tgcalls/commit/82c4921045c440b727c38e464f3a0539708423ff.patch";
    sha256 = "sha256-FIPelc6QQsQi9JYHaxjt87lE0foCYd7BNPrirUDp6VM=";
  };
in
stdenv.mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "unstable-2023-04-08";

  src = fetchFromGitHub {
    owner = "ilya-fedin";
    repo = "kotatogram-desktop";
    rev = "7e5535e1ecbb18d76b44c27e79981b75b417fef2";
    sha256 = "sha256-Tt7sYHsPbc798LEdbiXUBGVmZ1cy4K9UrJDA+EY8qw8=";
    fetchSubmodules = true;
  };

  patches = [
    ./shortcuts-binary-path.patch
  ];

  postPatch = ''
    patch -p1 -d Telegram/codegen < ${codegenPatch}
    patch -p1 -d Telegram/lib_ui < ${libUiPatch}
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
    extra-cmake-modules
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

  env.NIX_CFLAGS_COMPILE= optionalString stdenv.isLinux "-DQ_WAYLAND_CLIENT_EXPORT=";

  installPhase = optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r Kotatogram.app $out/Applications
    ln -s $out/Applications/Kotatogram.app/Contents/MacOS $out/bin
  '';

  preFixup = ''
    binName=${if stdenv.isLinux then "kotatogram-desktop" else "Kotatogram"}
    remove-references-to -t ${stdenv.cc.cc} $out/bin/$binName
    remove-references-to -t ${microsoft_gsl} $out/bin/$binName
    remove-references-to -t ${tg_owt.dev} $out/bin/$binName
  '';

  passthru = {
    inherit tg_owt;
  };

  meta = {
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
