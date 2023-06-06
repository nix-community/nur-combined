{ lib
, cmake
, fetchFromGitHub
, jellyfin-media-player
, libGL
, libX11
, libXrandr
, libvdpau
, mpv
, ninja
, pkg-config
, python3
, qt6
, SDL2
, stdenv
}:
(jellyfin-media-player.overrideAttrs (upstream: {
  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-media-player";
    rev = "qt6";
    hash = "sha256-saR/P2daqjF0G8N7BX6Rtsb1dWGjdf5MPDx1lhoioEw=";
  };
  # nixos ships two patches:
  # - the first fixes "web paths" and has *mostly* been upstreamed  (so skip and manually tweak a bit)
  # - the second disables auto-update notifications  (keep)
  patches = (builtins.tail upstream.patches) ++ [
    ./0001-fix-web-path.patch
    ./0002-qt6-build-fixes.patch
  ];
  buildInputs = [
    SDL2
    libGL
    libX11
    libXrandr
    libvdpau
    mpv
    qt6.qtbase
    qt6.qtwebchannel
    qt6.qtwebengine
    # qtx11extras
  ] ++ lib.optionals stdenv.isLinux [
    qt6.qtwayland
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3

    # new packages which weren't needed before
    qt6.wrapQtAppsHook  # replaces the implicit qt5 version
    qt6.qt5compat
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DQTROOT=${qt6.qtbase}"
    "-GNinja"
  ];

  meta = upstream.meta // {
    platforms = upstream.meta.platforms ++ [ "aarch64-linux" ];
  };
}))
