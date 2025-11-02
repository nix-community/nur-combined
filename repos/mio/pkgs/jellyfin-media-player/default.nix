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
  qtdeclarative,
  qtpositioning,
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
    qtdeclarative
    qtpositioning
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
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DQTROOT=${qtbase}"
    "-GNinja"
  ]
  ++ lib.optionals (!withDbus) [
    "-DLINUX_X11POWER=ON"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Prevent CMake from deploying Qt frameworks into the app bundle
    "-DQT_DEPLOY_SUPPORT=OFF"
    "-DCMAKE_SKIP_INSTALL_RPATH=ON"
  ];

  # On Darwin, we handle Qt environment setup manually to avoid broken library wrapping
  dontWrapQtApps = stdenv.hostPlatform.isDarwin;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
        mkdir -p $out/bin $out/Applications
        mv "$out/Jellyfin Media Player.app" $out/Applications
        
        # Remove any Qt frameworks that were copied into the bundle
        # We want to use Qt from the Nix store instead
        rm -rf "$out/Applications/Jellyfin Media Player.app/Contents/Frameworks/Qt"*.framework || true
        
        # Create a wrapper script that sets Qt environment variables
        cat > "$out/bin/jellyfinmediaplayer" << 'EOF'
    #!/bin/sh
    export QT_PLUGIN_PATH="${qtbase}/${qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${qtbase}/${qtbase.qtPluginPrefix}/platforms"
    export QML2_IMPORT_PATH="${qtbase}/${qtbase.qtQmlPrefix}"
    exec "$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player" "$@"
    EOF
        
        # Substitute the actual paths
        substituteInPlace "$out/bin/jellyfinmediaplayer" \
          --replace-fail '$out' "$out" \
          --replace-fail '${qtbase}' "${qtbase}"
        
        chmod +x "$out/bin/jellyfinmediaplayer"
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Fix all Qt framework references to point to Nix store instead of app bundle
    binary="$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player"

    # Change Qt framework paths from @executable_path to Nix store
    for framework in QtCore QtGui QtWidgets QtNetwork QtQml QtQuick QtWebChannel QtWebEngineCore QtWebEngineQuick QtCore5Compat QtOpenGL QtPositioning QtQmlModels QtQmlWorkerScript QtWebChannelQuick QtDBus QtXml QtQmlMeta; do
      old_path="@executable_path/../Frameworks/$framework.framework/Versions/A/$framework"
      # Find the framework in our dependencies
      if [ "$framework" = "QtCore5Compat" ]; then
        new_path="${qt5compat}/lib/$framework.framework/Versions/A/$framework"
      elif [ "$framework" = "QtWebEngineCore" ] || [ "$framework" = "QtWebEngineQuick" ]; then
        new_path="${qtwebengine}/lib/$framework.framework/Versions/A/$framework"
      elif [ "$framework" = "QtWebChannel" ] || [ "$framework" = "QtWebChannelQuick" ]; then
        new_path="${qtwebchannel}/lib/$framework.framework/Versions/A/$framework"
      elif [ "$framework" = "QtQml" ] || [ "$framework" = "QtQuick" ] || [ "$framework" = "QtQmlModels" ] || [ "$framework" = "QtQmlWorkerScript" ] || [ "$framework" = "QtQmlMeta" ]; then
        new_path="${qtdeclarative}/lib/$framework.framework/Versions/A/$framework"
      elif [ "$framework" = "QtPositioning" ]; then
        new_path="${qtpositioning}/lib/$framework.framework/Versions/A/$framework"
      else
        new_path="${qtbase}/lib/$framework.framework/Versions/A/$framework"
      fi
      
      # Only change if the framework exists in the target
      if [ -f "$new_path" ]; then
        install_name_tool -change "$old_path" "$new_path" "$binary" 2>/dev/null || true
      fi
    done
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
