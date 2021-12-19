{ lib
, stdenv
, fetchFromGitHub
, callPackage
, pkg-config
, cmake
, ninja
, python3
, wrapGAppsHook
, wrapQtAppsHook
, extra-cmake-modules
, qtbase
, qtimageformats
, qtsvg
, gtk3
, kwayland
, libdbusmenu
, lz4
, xxHash
, ffmpeg
, openalSoft
, minizip
, libopus
, alsa-lib
, libpulseaudio
, range-v3
, tl-expected
, hunspell
, glibmm
, webkitgtk
, jemalloc
, rnnoise
, abseil-cpp
, microsoft_gsl
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

let
  tg_owt = callPackage ./tg_owt.nix {
    abseil-cpp = (abseil-cpp.override {
      # abseil-cpp should use the same compiler
      stdenv = stdenv;
      cxxStandard = if stdenv.isDarwin then "14" else "17";
    }).overrideAttrs(_: {
      # https://github.com/NixOS/nixpkgs/issues/130963
      NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-lc++abi";
    });

    # tg_owt should use the same compiler
    stdenv = stdenv;

    Cocoa = Cocoa;
    AppKit = AppKit;
    IOKit = IOKit;
    IOSurface = IOSurface;
    Foundation = Foundation;
    AVFoundation = AVFoundation;
    CoreMedia = CoreMedia;
    VideoToolbox = VideoToolbox;
    CoreGraphics = CoreGraphics;
    CoreVideo = CoreVideo;
    OpenGL = OpenGL;
    Metal = Metal;
    MetalKit = MetalKit;
    CoreFoundation = CoreFoundation;
    ApplicationServices = ApplicationServices;
  };
  ver = "1.4.6";
in stdenv.mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "${ver}-1";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${ver}";
    sha256 = "sha256-KR81nihxAhfJXfAwV83mXIGp0afvLhS/mAgveG0ePQA=";
    fetchSubmodules = true;
  };

  patches = lib.optionals stdenv.isDarwin [
    # let it build with nixpkgs 10.12 sdk
    ./kotato-10.12-sdk.patch
    ./0001-Add-an-option-to-hide-messages-from-blocked-users-in.patch
  ];

  postPatch = lib.optionalString stdenv.isLinux ''
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace '"libpulse.so.0"' '"${libpulseaudio}/lib/libpulse.so.0"'
    substituteInPlace Telegram/lib_webview/webview/platform/linux/webview_linux_webkit_gtk.cpp \
      --replace '"libwebkit2gtk-4.0.so.37"' '"${webkitgtk}/lib/libwebkit2gtk-4.0.so.37"'
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace Telegram/CMakeLists.txt \
      --replace 'COMMAND iconutil' 'COMMAND png2icns'
    substituteInPlace Telegram/CMakeLists.txt \
      --replace '--convert icns' ""
    substituteInPlace Telegram/CMakeLists.txt \
      --replace '--output AppIcon.icns' 'AppIcon.icns'
    substituteInPlace Telegram/CMakeLists.txt --replace "\''${appicon_path}" \
      "\''${appicon_path}/icon_16x16.png \''${appicon_path}/icon_32x32.png \''${appicon_path}/icon_128x128.png \''${appicon_path}/icon_256x256.png \''${appicon_path}/icon_512x512.png"
  '';

  # We want to run wrapProgram manually (with additional parameters)
  dontWrapGApps = stdenv.isLinux;
  dontWrapQtApps = stdenv.isLinux;

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    wrapQtAppsHook
  ] ++ lib.optionals stdenv.isLinux [
    wrapGAppsHook
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase
    qtimageformats
    qtsvg
    lz4
    xxHash
    ffmpeg
    openalSoft
    minizip
    libopus
    range-v3
    tl-expected
    rnnoise
    tg_owt
    microsoft_gsl
  ] ++ lib.optionals stdenv.isLinux [
    gtk3
    kwayland
    libdbusmenu
    alsa-lib
    libpulseaudio
    hunspell
    glibmm
    webkitgtk
    jemalloc
  ] ++ lib.optionals stdenv.isDarwin [
    libicns
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
  ];

  # https://github.com/NixOS/nixpkgs/issues/130963
  NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-lc++abi";

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DTDESKTOP_API_TEST=ON"
    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
    "-DDESKTOP_APP_QT6=OFF"
  ];

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r Kotatogram.app $out/Applications
    ln -s $out/Applications/Kotatogram.app/Contents/MacOS $out/bin
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/kotatogram-desktop \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}"
  '';

  passthru = {
    inherit tg_owt;
  };

  meta = with lib; {
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.

      It contains some useful (or purely cosmetic) features, but they could be unstable. A detailed list is available here: https://kotatogram.github.io/changes
    '';
    license = licenses.gpl3;
    platforms = platforms.all;
    homepage = "https://kotatogram.github.io";
    changelog = "https://github.com/kotatogram/kotatogram-desktop/releases/tag/k{ver}";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
