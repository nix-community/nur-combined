{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  unzip,
  wayland,
}:

let
  pname = "ps5upload";
  version = "5.41.0";

  cpu = stdenvNoCC.hostPlatform.parsed.cpu.name;

  # upstream names the linux release archives x64 / arm64
  arch =
    {
      x86_64 = "x64";
      aarch64 = "arm64";
    }
    .${cpu} or (throw "ps5upload: unsupported cpu ${cpu}");

  release = fetchurl {
    url = "https://github.com/phantomptr/ps5upload/releases/download/v${version}/PS5Upload-${version}-linux-${arch}.zip";
    hash =
      {
        x86_64 = "sha256-ueLIMeG1R/HNX6AEN0oDNTNk15u87jRYnvhO6RHoqcM=";
        aarch64 = "sha256-Y2KJDdbh6ipq1noZ7NFnsSG3cwoXE9s+pmGBbFR5Eiw=";
      }
      .${cpu} or (throw "ps5upload: unsupported cpu ${cpu}");
  };

  appimage = stdenvNoCC.mkDerivation {
    name = "${pname}-${version}-appimage";

    src = release;

    nativeBuildInputs = [ unzip ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      unzip -q $src PS5Upload.AppImage
      install -Dm755 PS5Upload.AppImage $out/PS5Upload.AppImage

      runHook postInstall
    '';
  };

  src = "${appimage}/PS5Upload.AppImage";

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/PS5Upload.desktop $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=ps5upload-desktop' 'Exec=${pname}' \
      --replace-fail 'Icon=ps5upload-desktop' 'Icon=${pname}'

    for size in 32x32 128x128 256x256@2; do
      install -Dm644 ${appimageContents}/usr/share/icons/hicolor/$size/apps/ps5upload-desktop.png \
        $out/share/icons/hicolor/$size/apps/${pname}.png
    done

    # the AppImage bundles an old libwayland-client that shadows the nix one, so
    # libEGL cannot resolve wl_fixes_interface, the webkit GPU process aborts with
    # "Could not create default EGL display" and the webview stays empty; preloading
    # the nix copy fixes it (same trick as upstream's own launcher). The AppImage
    # also ships no gstreamer plugins at all, but webkit's bundled libgstreamer still
    # rescans QT_PLUGIN_PATH and floods stderr with "Failed to load plugin" warnings
    # about unrelated kde/qt plugins, so drop it.
    wrapProgram "$out/bin/${pname}" \
      --set QT_PLUGIN_PATH "" \
      --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1 \
      --set-default LD_PRELOAD "${wayland}/lib/libwayland-client.so.0"
  '';

  meta = {
    description = "All-in-one PS5 companion app to transfer, install and manage games, saves and homebrew";
    homepage = "https://github.com/phantomptr/ps5upload";
    # gpl3 for the app itself, unfree for the bundled UnRAR library (.rar support)
    license = with lib.licenses; [
      gpl3Only
      unfree
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = pname;
  };
}
