{
  lib,
  fetchFromGitHub,
  fetchpatch,
  stdenv,
  SDL2,
  cmake,
  libGL,
  libiconv,
  libX11,
  libXrandr,
  libvdpau,
  mpv,
  ninja,
  pkg-config,
  python3,
  qtbase,
  qt5compat,
  qtwayland,
  qtwebchannel,
  qtwebengine,
  wrapQtAppsHook,
  withDbus ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation rec {
  pname = "jellyfin-media-player";
  version = "1.12.0-unstable-2025-10-29";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-media-player";
    rev = "67d1298b4c2e4d302bb9f818dd48f1794b4a3aac";
    hash = "sha256-SO4Iyao6Ivdj6QWrUlTVQYPed5/8F30zZlPzX9jPqRE=";
  };

  patches = [
    # disable update notifications since the end user can't simply download the release artifacts to update
    ./disable-update-notifications.patch
  ];

  buildInputs = [
    SDL2
    libGL
    libX11
    libXrandr
    libvdpau
    mpv
    qtbase
    qt5compat
    qtwebchannel
    qtwebengine
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qtwayland
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DQTROOT=${qtbase}"
    "-GNinja"
  ]
  ++ lib.optionals (!withDbus) [
    "-DLINUX_X11POWER=ON"
  ];

  # Prevent Qt wrapper from creating broken executable stubs for libraries on Darwin
  dontWrapQtApps = stdenv.hostPlatform.isDarwin;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin $out/Applications
    mv "$out/Jellyfin Media Player.app" $out/Applications

    # Manually wrap the app since we disabled dontWrapQtApps
    # Set up Qt plugin path and QML import path
    wrapQtApp "$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player"

    ln -s "$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player" $out/bin/jellyfinmediaplayer
  '';

  meta = with lib; {
    homepage = "https://github.com/jellyfin/jellyfin-media-player";
    description = "Jellyfin Desktop Client based on Plex Media Player";
    license = with licenses; [
      gpl2Only
      mit
    ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    maintainers = with maintainers; [
      jojosch
      kranzes
      paumr
    ];
    mainProgram = "jellyfinmediaplayer";
  };
}
