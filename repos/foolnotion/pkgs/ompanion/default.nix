{
  autoPatchelfHook,
  fetchzip,
  gtk4,
  lib,
  libsecret,
  libsoup_3,
  makeWrapper,
  stdenv,
  webkitgtk_6_0,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ompanion";
  version = "2.2.0";

  src = fetchzip {
    url = "https://github.com/edde746/ompanion/releases/download/${finalAttrs.version}/ompanion-linux-x64.zip";
    hash = "sha256-4scfSB1r6klleMc+G2E02tY8SiSNSXrbyhd19BR3Dis=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gtk4
    libsecret
    libsoup_3
    webkitgtk_6_0
  ];
  installPhase = ''
    runHook preInstall

    install -d "$out/libexec/ompanion"
    install -Dm755 ompanion "$out/libexec/ompanion/ompanion"
    install -Dm755 libompcore.so "$out/libexec/ompanion/libompcore.so"
    cp -r ui "$out/libexec/ompanion/ui"
    cp -r icons "$out/libexec/ompanion/icons"

    makeWrapper "$out/libexec/ompanion/ompanion" "$out/bin/ompanion"
    install -Dm644 icons/com.edde746.ompanion.png \
      "$out/share/icons/hicolor/512x512/apps/com.edde746.ompanion.png"
    install -Dm644 /dev/stdin "$out/share/applications/com.edde746.ompanion.desktop" <<'DESKTOP'
    [Desktop Entry]
    Name=ompanion
    Comment=Desktop client for omp over SSH and Tailscale
    Exec=ompanion
    Icon=com.edde746.ompanion
    Terminal=false
    Type=Application
    Categories=Development;IDE;
    DESKTOP

    runHook postInstall
  '';

  meta = {
    description = "Desktop client for omp over SSH and Tailscale";
    homepage = "https://ompanion.app/";
    downloadPage = "https://github.com/edde746/ompanion/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "ompanion";
    platforms = [ "x86_64-linux" ];
  };
})
