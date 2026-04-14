{ lib
, stdenv
, fetchFromGitHub
, electron
, makeWrapper
, wrapGAppsHook3
}:

stdenv.mkDerivation rec {
  pname = "claude-desktop";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "simongettkandt";
    repo = "claude-ai-desktop-app";
    rev = "2cc2b82b0da5660850b4585e96e73c11ecfddbf3";
    hash = "sha256-E2QdHGsuo5W9nZ3xbaL+ZIpl8/n/TVPRxqbpVjOwWeM=";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    electron
  ];

  installPhase = ''
    runHook preInstall

    # Install app files to lib directory
    mkdir -p "$out/lib/claude-desktop"
    cp -r ./* "$out/lib/claude-desktop"

    # Remove unnecessary files
    rm -rf "$out/lib/claude-desktop/.git" "$out/lib/claude-desktop/.github"
    rm -f "$out/lib/claude-desktop/node_modules"

    # Create a wrapper script that uses system electron
    mkdir -p "$out/bin"
    makeWrapper ${electron}/bin/electron "$out/bin/claude-desktop" \
      --add-flags "$out/lib/claude-desktop/main.js"

    # Install desktop file
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/claude-desktop.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Claude Desktop
Comment=Claude AI Desktop Application for Linux
Exec=claude-desktop %u
Icon=electron
Terminal=false
Categories=Development;Utility;
Keywords=claude;ai;assistant;
EOF

    # Install icon
    mkdir -p "$out/share/icons/hicolor/256x256/apps"
    cp "$out/lib/claude-desktop/icon.png" "$out/share/icons/hicolor/256x256/apps/claude-desktop.png"

    runHook postInstall
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Claude AI Desktop Application for Linux";
    homepage = "https://github.com/simongettkandt/claude-ai-desktop-app";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
