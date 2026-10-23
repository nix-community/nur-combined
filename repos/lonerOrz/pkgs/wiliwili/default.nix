{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  cmake,
  ninja,
  pkg-config,

  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,

  mpv-unwrapped,
  SDL2,
  libwebp,

  egl-wayland,
  libX11,
  libXcursor,
  libXfixes,
  libXi,
  libXrandr,
  libxinerama,
  libxkbcommon,
  mesa,
  wayland,
  wayland-scanner,

  cairo,
  dbus,
  fontconfig,
  freetype,
  openssl,
  pulseaudio,
  udev,

  curl,
  fmt,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wiliwili";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "xfangfang";
    repo = "wiliwili";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J6oUMUzfogsIBj1GpwWmKhjphTV628rG+3w28Dc81Fw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    # Build system
    cmake
    ninja
    pkg-config

    # Desktop integration
    copyDesktopItems

    # Executable wrapping
    makeWrapper

    # Wayland protocol
    wayland-scanner
  ];

  buildInputs = [
    # Multimedia
    SDL2
    libwebp
    mpv-unwrapped

    # Graphics and display
    egl-wayland
    libX11
    libXcursor
    libXfixes
    libXi
    libXrandr
    libxinerama
    libxkbcommon
    mesa
    wayland

    # Audio
    pulseaudio

    # Fonts and rendering
    cairo
    fontconfig
    freetype

    # Networking
    curl

    # System integration
    dbus
    udev

    # C++ libraries
    fmt
    nlohmann_json

    # Cryptography
    openssl
  ];

  cmakeFlags = [
    "-DCPR_FORCE_USE_SYSTEM_CURL=ON"
    "-DGLFW_BUILD_WAYLAND=ON"
    "-DGLFW_BUILD_X11=ON"
    "-DINSTALL=ON"
    "-DPLATFORM_DESKTOP=ON"
    "-DUSE_EGL=ON"
    "-DUSE_GLES2=OFF"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "cn.xfangfang.wiliwili";
      desktopName = "WiliWili";
      comment = "Bilibili video client";
      exec = "wiliwili %u";
      icon = "cn.xfangfang.wiliwili";
      categories = [
        "Network"
        "Video"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A cross-platform Bilibili client built with borealis";
    homepage = "https://github.com/xfangfang/wiliwili";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wiliwili";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
