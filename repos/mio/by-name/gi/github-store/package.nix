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
  pname = "github-store";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "OpenHub-Store";
    repo = "GitHub-Store";
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
      $out/share/icons/hicolor/512x512/apps/github-store.png

    # Distributable launcher is named after packageName
    ln -s Komi-Store $out/bin/github-store

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "github-store";
      exec = "github-store";
      icon = "github-store";
      desktopName = "GitHub Store";
      comment = finalAttrs.meta.description;
      categories = [ "Development" ];
    })
  ];

  meta = {
    description = "Cross-platform app store for GitHub releases";
    homepage = "https://github.com/OpenHub-Store/GitHub-Store";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "github-store";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
