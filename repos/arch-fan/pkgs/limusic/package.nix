{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  wrapGAppsHook3,
  glib-networking,
  gtk3,
  libayatana-appindicator,
  libGL,
  libsoup_3,
  libx11,
  libxi,
  mpv-unwrapped,
  openssl,
  webkitgtk_4_1,
}:

# The upstream .deb is the release binary (official Last.fm keys, no AppImage
# self-updater) linked against system libraries, which we take from nixpkgs.
stdenv.mkDerivation (finalAttrs: {
  pname = "limusic";
  version = "1.4.1";

  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${finalAttrs.version}/limusic_${finalAttrs.version}_amd64.deb";
    hash = "sha256-37GWCHMfCpr6KFn+ZeMJWNfwbZf52J7XItuh4TTcwcs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking # TLS for the webview
    gtk3
    libsoup_3
    mpv-unwrapped
    openssl
    webkitgtk_4_1
  ];

  # dlopen()ed: the tray icon, GL for the webview, XInput.
  runtimeDependencies = [
    libayatana-appindicator
    libGL
    libx11
    libxi
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/bin usr/share $out/
    ln -s limusic-app $out/bin/limusic
    # Name it after the window's app id so docks match the two up.
    mv $out/share/applications/limusic.desktop $out/share/applications/limusic-app.desktop

    runHook postInstall
  '';

  meta = {
    description = "Native desktop YouTube Music client";
    homepage = "https://github.com/SimoHypers/limusic";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "limusic";
  };
})
