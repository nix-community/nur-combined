{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  gradle-packages,
  jdk25,
  autoPatchelfHook,
  binutils,
  copyDesktopItems,
  git,
  makeDesktopItem,
  makeWrapper,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  file,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libxkbcommon,
  pango,
  wayland,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxtst,
}:

let
  gradleUnwrapped = gradle-packages.mkGradle {
    version = "9.3.1";
    hash = "sha256-smbV/2uQ6tptw7IMsJDjcxMC5VOifF0+TfHw12vq/wY=";
    defaultJava = jdk25;
  };

  gradle = callPackage gradle-packages.wrapGradle {
    gradle-unwrapped = gradleUnwrapped;
  };

  appName = "ABDownloadManager";
  runtimeLibs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    file
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libxkbcommon
    pango
    wayland
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    libxtst
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "amir1376";
    repo = "ab-download-manager";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4Nb6nRIWmiQqvPTCf4sGUtbWr4NqQX5PTy3oSVgu+aE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    binutils
    copyDesktopItems
    git
    gradle
    jdk25
    makeWrapper
  ];

  buildInputs = runtimeLibs;
  runtimeDependencies = runtimeLibs;

  dontUseGradleCheck = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  gradleBuildTask = ":desktop:app:createReleaseDistributable";
  gradleUpdateTask = ":desktop:app:createReleaseDistributable";

  postPatch = ''
    substituteInPlace desktop/app/build.gradle.kts \
      --replace-fail 'from(tasks.named("createReleaseDistributable"))' 'dependsOn("createReleaseDistributable")
    from(layout.buildDirectory.dir("compose/binaries/main-release/app/$appPackageNameByComposePlugin"))'
  '';

  preConfigure = ''
    export JAVA_HOME="${jdk25.home}"
    export GITHUB_CI=true
    export GITHUB_REF="refs/tags/v${finalAttrs.version}"
    export GITHUB_SHA="0000000000000000000000000000000000000000"
  '';

  installPhase = ''
    runHook preInstall

    appDir="$out/opt/${appName}"
    mkdir -p "$out/bin" "$appDir" "$out/share/pixmaps"
    cp -r "desktop/app/build/compose/binaries/main-release/app/${appName}/." "$appDir/"

    install -Dm644 "desktop/app/icons/icon.png" "$out/share/icons/hicolor/512x512/apps/${finalAttrs.pname}.png"
    ln -s "$out/share/icons/hicolor/512x512/apps/${finalAttrs.pname}.png" "$out/share/pixmaps/${finalAttrs.pname}.png"

    makeWrapper "$appDir/bin/${appName}" "$out/bin/${appName}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}:$appDir/lib/runtime/lib:$appDir/lib/runtime/lib/server:$appDir/lib" \
      --set-default _JAVA_AWT_WM_NONREPARENTING 1

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "AB Download Manager";
      exec = appName;
      icon = finalAttrs.pname;
      comment = "Download manager";
      categories = [
        "Network"
        "FileTransfer"
      ];
      startupWMClass = "com-abdownloadmanager-desktop-AppKt";
    })
  ];

  # nix eval --raw .#ab-download-manager.passthru.fetch-deps.passthru.updateScript
  passthru.fetch-deps = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  meta = {
    description = "Desktop download manager";
    homepage = "https://github.com/amir1376/ab-download-manager";
    license = lib.licenses.asl20;
    mainProgram = appName;
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
