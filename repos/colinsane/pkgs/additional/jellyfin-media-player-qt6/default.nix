{ lib
, buildPackages
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
    hash = "sha256-CXuK6PLGOiBDbnLqXcr5sUtQmXksMc6X6GKVMEzmu30=";
  };
  # nixos ships two patches:
  # - the first fixes "web paths" and has *mostly* been upstreamed  (so skip and manually tweak a bit)
  # - the second disables auto-update notifications  (keep)
  patches = (builtins.tail upstream.patches) ++ [
    ./0001-fix-web-path.patch
    # ./0002-qt6-build-fixes.patch
    # ./0003-qt6-components-webengine.patch
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
    qt6.qt5compat  #< new
  ] ++ lib.optionals stdenv.isLinux [
    qt6.qtwayland
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
    qt6.wrapQtAppsHook  #< new: libsForQt5.callPackage implicitly adds the qt5 wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DQTROOT=${qt6.qtbase}"
    "-GNinja"
    # "-DQT_DEBUG_FIND_PACKAGE=ON"
    # "--debug-find-pkg=Qt6WebEngineQuick"
  ];

  meta = upstream.meta // {
    platforms = upstream.meta.platforms ++ [ "aarch64-linux" ];
  };
}))
