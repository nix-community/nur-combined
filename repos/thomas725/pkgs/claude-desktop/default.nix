{ lib
, stdenv
, fetchurl
, appimageTools
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook3
, patchelf
, glib
, gtk3
, libnotify
, libxkbcommon
, mesa
, nss
, nspr
, alsa-lib
, pulseaudio
, dbus
, xorg
}:

let
  version = "1.3.0";
  releaseTag = "v.1.3.0";
  appImage = fetchurl {
    url = "https://github.com/simongettkandt/claude-ai-desktop-app/releases/download/${releaseTag}/Claude-Desktop-${version}.AppImage";
    hash = "sha256-24XyCEGZ9Y6Gji8h3IJ9OahWWH9NyuURK3ByN3uk7p8=";
  };
  appimageContents = appimageTools.extractType2 {
    pname = "claude-desktop";
    inherit version;
    src = appImage;
  };
in
stdenv.mkDerivation {
  pname = "claude-desktop";
  inherit version;

  src = appImage;
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libnotify
    libxkbcommon
    mesa
    nss
    nspr
    alsa-lib
    pulseaudio
    dbus
    xorg.libX11
    xorg.libxcb
    xorg.libXi
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libdbusmenu-gtk.so.4"
    "libdbusmenu-glib.so.4"
    "libgtk-x11-2.0.so.0"
    "libdbus-glib-1.so.2"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/applications" "$out/lib-inject"

    # Extract and copy the app contents
    cp -r ${appimageContents}/* "$out/" || true

    # Remove extracted bin/claude-desktop if it exists to avoid conflicts
    rm -f "$out/bin/claude-desktop" "$out/bin/.claude-desktop-wrapped" 2>/dev/null || true

    # Copy Mesa and other libraries needed, renamed for ELF compatibility
    cp ${mesa}/lib/libEGL_mesa.so.0 "$out/lib-inject/libEGL.so.1"
    cp ${mesa}/lib/libGLESv2.so.2 "$out/lib-inject/libGLESv2.so.2" 2>/dev/null || true
    cp ${mesa}/lib/libgbm.so.1 "$out/lib-inject/libgbm.so.1" 2>/dev/null || true
    cp ${libxkbcommon}/lib/libxkbcommon.so.0 "$out/lib-inject/" 2>/dev/null || true

    # Symlink icudtl.dat to bin directory so it's found
    if [ -f "$out/icudtl.dat" ]; then
      ln -s "$out/icudtl.dat" "$out/bin/icudtl.dat"
    fi

    # Create wrapper script that sets up LD_LIBRARY_PATH to inject our libraries first
    # Disable GPU and auto-update due to missing EGL libraries
    if [ -f "$out/claude-desktop" ]; then
      mv "$out/claude-desktop" "$out/.claude-desktop.real"
      cat > "$out/bin/claude-desktop-runner" << 'WRAPPER'
#!/bin/sh
cd "$(dirname "$0")/.." || exit 1
export LD_LIBRARY_PATH="$PWD/lib-inject:$PWD/lib:$LD_LIBRARY_PATH"
export DISABLE_GPU_SANDBOX=1
# Pass --no-update to disable self-updating and --disable-gpu for rendering
exec ./.claude-desktop.real --no-update --disable-gpu --enable-logging "$@"
WRAPPER
      chmod +x "$out/bin/claude-desktop-runner"
      makeWrapper "$out/bin/claude-desktop-runner" "$out/bin/claude-desktop" \
        --prefix LD_LIBRARY_PATH : "${pulseaudio}/lib" \
        --inherit-argv0
    elif [ -f "$out/AppRun" ]; then
      cat > "$out/bin/claude-desktop-runner" << 'WRAPPER'
#!/bin/sh
cd "$(dirname "$0")/.." || exit 1
export LD_LIBRARY_PATH="$PWD/lib-inject:$PWD/lib:$LD_LIBRARY_PATH"
export DISABLE_GPU_SANDBOX=1
exec ./AppRun --no-update --disable-gpu --enable-logging "$@"
WRAPPER
      chmod +x "$out/bin/claude-desktop-runner"
      makeWrapper "$out/bin/claude-desktop-runner" "$out/bin/claude-desktop" \
        --prefix LD_LIBRARY_PATH : "${pulseaudio}/lib" \
        --inherit-argv0
    fi

    # Install desktop file
    cat > "$out/share/applications/claude-desktop.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Claude Desktop
Comment=Claude AI Desktop Application for Linux
Exec=$out/bin/claude-desktop %u
Icon=electron
Terminal=false
Categories=Development;Utility;
Keywords=claude;ai;assistant;
EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude AI Desktop Application for Linux";
    homepage = "https://github.com/simongettkandt/claude-ai-desktop-app";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
