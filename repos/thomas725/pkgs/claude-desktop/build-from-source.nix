# Claude Desktop - Built from source using Node.js/Electron
# This avoids EGL compatibility issues with pre-built AppImages
# Source: https://github.com/simongettkandt/claude-ai-desktop-app
# Uses Electron 41.2.1 which is compatible with current Mesa

{ lib
, stdenv
, fetchFromGitHub
, nodejs_22
, makeWrapper
, libxkbcommon
, mesa
, electron
}:

let
  version = "1.3.0";
  electron_version = "41.2.1";
in
stdenv.mkDerivation {
  pname = "claude-desktop";
  inherit version;

  src = fetchFromGitHub {
    owner = "simongettkandt";
    repo = "claude-ai-desktop-app";
    rev = "v.${version}";
    hash = "sha256-wCpf6Th6rvE6Ftnn1GL+TE/QeeP3oqbGH7+DRUJeUsA=";
  };

  nativeBuildInputs = [
    nodejs_22
    makeWrapper
  ];

  dontUnpack = false;

  # Set environment variables to prevent Electron from downloading binaries at build time
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  env.npm_config_nodedir = "${nodejs_22}";

  # Provide pre-built Electron to npm/electron-builder
  postUnpack = ''
    # Use pre-downloaded Electron instead of letting npm download it
    export PATH="${electron}/bin:$PATH"
  '';

  # Build phase: install dependencies and build AppImage
  buildPhase = ''
    set -x  # Verbose output for debugging

    # Install dependencies with timeout and verbose output
    echo "Installing npm dependencies..."
    timeout 300 npm install --no-save --no-audit --no-fund 2>&1 || true

    echo "Verifying npm install completed..."
    if [ ! -d node_modules ]; then
      echo "ERROR: node_modules directory not created"
      exit 1
    fi

    echo "Building AppImage with electron-builder..."
    timeout 600 npm run build-appimage -- --publish never || true

    echo "Checking for output..."
    ls -lah dist/ || echo "dist/ directory not found"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications

    # Find the generated AppImage in dist folder
    APPIMAGE=$(find dist -name "*.AppImage" -type f 2>/dev/null | head -1)

    if [ -z "$APPIMAGE" ]; then
      echo "Error: No AppImage found in dist/ after build"
      ls -la dist/ 2>/dev/null || echo "dist/ doesn't exist"
      exit 1
    fi

    echo "Found AppImage: $APPIMAGE"
    chmod +x "$APPIMAGE"

    # Copy AppImage to output
    cp "$APPIMAGE" $out/claude-desktop.AppImage
    chmod +x $out/claude-desktop.AppImage

    # Create a wrapper script that runs the AppImage
    # Using --no-sandbox because the Chrome SUID sandbox doesn't work in AppImages
    makeWrapper $out/claude-desktop.AppImage $out/bin/claude-desktop \
      --add-flags "--no-sandbox"

    # Create desktop entry
    cat > $out/share/applications/claude-desktop.desktop <<'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=Claude Desktop
Comment=Claude AI Desktop Application
Exec=$out/bin/claude-desktop %u
Icon=electron
Terminal=false
Categories=Development;Utility;
Keywords=claude;ai;assistant;
DESKTOP

    # Fix the Exec path in desktop entry
    sed -i "s|\$out|$out|g" $out/share/applications/claude-desktop.desktop
  '';

  meta = with lib; {
    description = "Claude AI Desktop Application (built from source with Electron 41)";
    longDescription = ''
      Claude Desktop application built from source to ensure compatibility with
      current Mesa libraries. Uses Electron 41.2.1 which works with modern OpenGL/EGL.
    '';
    homepage = "https://github.com/simongettkandt/claude-ai-desktop-app";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "claude-desktop";
  };
}
