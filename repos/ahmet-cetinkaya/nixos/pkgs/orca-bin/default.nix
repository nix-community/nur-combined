{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "orca-bin";
  version = "1.4.146";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-/DQnU0U4XyOAxYX7J81gCJP2OgaLxTARr4kUpvqdT8k=";
  };

  # Extract the AppImage contents so we can lift out the .desktop entry and
  # icons and rewire the Exec line to the wrapped binary.
  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      # Desktop entry: point Exec at the wrapped binary and keep --no-sandbox,
      # which the upstream AppImage requires under an Electron sandbox.
      install -Dm644 "${appimageContents}/orca-ide.desktop" \
        "$out/share/applications/orca-ide.desktop"
      substituteInPlace "$out/share/applications/orca-ide.desktop" \
        --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=orca-bin --no-sandbox %U"

      # Theme-aware icons.
      for size in 16 32 48 64 128 256 512 1024; do
        src="${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/orca-ide.png"
        if [ -f "$src" ]; then
          install -Dm644 "$src" \
            "$out/share/icons/hicolor/''${size}x''${size}/apps/orca-ide.png"
        fi
      done
    '';

    # Electron / Chromium runtime dependencies (mirrors the AUR PKGBUILD deps:
    # gtk3, nss, alsa-lib, libnotify, libXScrnSaver, libXtst, libsecret, ...).
    extraPkgs = pkgs:
      with pkgs; [
        alsa-lib
        gtk3
        libnotify
        libsecret
        nss
        libxscrnsaver
        libxtst
      ];

    meta = with lib; {
      description = "Stably AI Orca - Electron-based agentic coding IDE (ADE for a fleet of parallel agents)";
      homepage = "https://github.com/stablyai/orca";
      license = licenses.mit;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "orca-bin";
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };
  }
