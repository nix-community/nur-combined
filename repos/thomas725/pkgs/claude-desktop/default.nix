{ lib
, stdenv
, fetchurl
, appimageTools
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook3
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
  version = "1.3.0-beta.1";
  releaseTag = "v.1.3.0-Beta.01";
  appImage = fetchurl {
    url = "https://github.com/simongettkandt/claude-ai-desktop-app/releases/download/${releaseTag}/Claude-Desktop-${version}.AppImage";
    hash = "sha256-EauLt8SSPCwuZPmNlz7XknCMjlZ3CLGNwJc+vG05lHU=";
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

    mkdir -p "$out/bin" "$out/share/applications"

    # Extract and copy the app contents
    cp -r ${appimageContents}/* "$out/" || true

    # Remove extracted bin/claude-desktop if it exists to avoid conflicts
    rm -f "$out/bin/claude-desktop" "$out/bin/.claude-desktop-wrapped" 2>/dev/null || true

    # Symlink icudtl.dat to bin directory so it's found
    if [ -f "$out/icudtl.dat" ]; then
      ln -s "$out/icudtl.dat" "$out/bin/icudtl.dat"
    fi

    # Create wrapper script that runs from the app root directory with audio support
    if [ -f "$out/claude-desktop" ]; then
      mv "$out/claude-desktop" "$out/.claude-desktop.real"
      cat > "$out/bin/claude-desktop-runner" << 'WRAPPER'
#!/bin/sh
cd "$(dirname "$0")/.." || exit 1
exec ./.claude-desktop.real "$@"
WRAPPER
      chmod +x "$out/bin/claude-desktop-runner"
      makeWrapper "$out/bin/claude-desktop-runner" "$out/bin/claude-desktop" \
        --prefix LD_LIBRARY_PATH : ".:./lib:${pulseaudio}/lib" \
        --inherit-argv0
    elif [ -f "$out/AppRun" ]; then
      cat > "$out/bin/claude-desktop-runner" << 'WRAPPER'
#!/bin/sh
cd "$(dirname "$0")/.." || exit 1
exec ./AppRun "$@"
WRAPPER
      chmod +x "$out/bin/claude-desktop-runner"
      makeWrapper "$out/bin/claude-desktop-runner" "$out/bin/claude-desktop" \
        --prefix LD_LIBRARY_PATH : ".:./lib:${pulseaudio}/lib" \
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
