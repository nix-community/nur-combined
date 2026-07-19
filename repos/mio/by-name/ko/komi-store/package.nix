{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  jdk21,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  file,
  alsa-lib,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libxkbcommon,
  libx11,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxcursor,
  libxi,
  libxinerama,
  libxrender,
  libxscrnsaver,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "komi-store";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "kurikomi-labs";
    repo = "komi-store";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oRGkXLoH8+bzy3NE2rdtW3qgqT2c+z2y0qmwosatAeg=";
  };

  # Desktop-only build: drop Android Gradle plugins/deps (no Android SDK in nix).
  patches = [
    ./compose-repo.patch
    ./build-logic-pluginmanagement.patch
    ./disable-android-convention.patch
    ./disable-android-composeapp.patch
  ];

  nativeBuildInputs = [
    gradle
    jdk21
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    file
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    libx11
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    libxcb
  ];

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  __darwinAllowLocalNetworking = true;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk21}"
    "-Dfile.encoding=utf-8"
  ];

  gradleBuildTask = "composeApp:createDistributable";
  gradleUpdateTask = "composeApp:createDistributable";

  env.JAVA_HOME = jdk21;

  installPhase = ''
    runHook preInstall

    # Compose Multiplatform packageName = "Komi-Store"
    cp -r composeApp/build/compose/binaries/main/app/Komi-Store $out

    install -Dm644 composeApp/src/jvmMain/resources/logo/app_icon.png \
      $out/share/icons/hicolor/512x512/apps/komi-store.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "komi-store";
      exec = "Komi-Store";
      icon = "komi-store";
      desktopName = "Komi Store";
      comment = finalAttrs.meta.description;
      categories = [ "Development" ];
    })
  ];

  meta = {
    description = "Cross-platform app store for GitHub releases";
    homepage = "https://github.com/kurikomi-labs/komi-store";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "Komi-Store";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
