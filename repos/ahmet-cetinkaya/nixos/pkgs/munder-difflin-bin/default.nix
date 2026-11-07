{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "munder-difflin-bin";
  version = "0.5.5";

  src = fetchurl {
    url = "https://github.com/HarnessMD/munder-difflin/releases/download/v${version}/Munder-Difflin-${version}-linux-x86_64.AppImage";
    hash = "sha256-FUc0X+/R+tglejsfPJTQrSLVaoATC/pypPEaqE24ZCs=";
  };

  # Extract the AppImage contents so we can lift out the .desktop entry and
  # icons and rewire the Exec line to the wrapped binary.
  appimageContents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      # Desktop entry: point Exec at the wrapped binary and keep --no-sandbox,
      # which the upstream AppImage requires under an Electron sandbox.
      install -Dm644 "${appimageContents}/munder-difflin.desktop" \
        "$out/share/applications/munder-difflin.desktop"
      substituteInPlace "$out/share/applications/munder-difflin.desktop" \
        --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=munder-difflin-bin --no-sandbox %U"

      install -Dm644 \
        "${appimageContents}/usr/share/icons/hicolor/512x512/apps/munder-difflin.png" \
        "$out/share/icons/hicolor/512x512/apps/munder-difflin.png"
    '';

    # Electron / Chromium runtime dependencies (mirrors the orca-bin pattern;
    # the AppImage bundles its own Electron, so no system electron is needed).
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
      description = "Agent harness to run an office of your clones";
      homepage = "https://munderdiffl.in";
      license = licenses.mit;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "munder-difflin-bin";
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };
  }
