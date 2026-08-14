{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  jdk21,
  fontconfig,
  libxinerama,
  libxrandr,
  file,
  gtk3,
  glib,
  cups,
  lcms2,
  alsa-lib,
  libglvnd,
  udev,
  dconf,
  dpkg,
  rpm,
  gsettings-desktop-schemas,
  hicolor-icon-theme,
  adwaita-icon-theme,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  autoPatchelfHook,
  writeShellApplication,
  writeShellScriptBin,
  nix-update,
  git,
  nix,
  coreutils,
  kdePackages,
  desktopToDarwinBundle,
}:

let
  kreadconfig5Shim = writeShellScriptBin "kreadconfig5" ''
    exec ${lib.getExe' kdePackages.kconfig "kreadconfig6"} "$@"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bifrost";
  version = "2.1.3";

  strictDeps = true;

  src = fetchFromGitHub {
    owner = "zacharee";
    repo = "Bifrost";
    tag = finalAttrs.version;
    hash = "sha256-0LnErYWnsLhFIrZujaVXWLgGRtGXladxfsI0uJ/Fv2c=";
  };

  patches = [
    ./0001-fix-gradle-plugin-and-desktop-toolchain.patch
    ./0002-remove-foojay-resolver.patch
    ./0003-desktop-only-skip-android-ios.patch
  ];

  postPatch = ''
    echo "kotlin.native.ignoreDisabledTargets=true" >> local.properties
    substituteInPlace desktop/build.gradle.kts \
      --replace-fail 'nativeDistributions {' 'nativeDistributions { modules("java.sql");'
    substituteInPlace gradle.properties \
      --replace-fail 'org.gradle.jvmargs=-Xmx8192M -Dkotlin.daemon.jvm.options\="-Xmx2048M"' \
      'org.gradle.jvmargs=-Dfile.encoding=UTF-8'
    echo 'org.gradle.vfs.watch=false' >> gradle.properties
  '';

  gradleBuildTask = ":desktop:createReleaseDistributable";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  gradleUpdateScript = ''
    runHook preBuild

    gradle :desktop:checkRuntime -PskipAndroid=true -Dos.family=linux -Dos.arch=amd64
    gradle :common:compileKotlinJvm -PskipAndroid=true
    gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.family=linux -Dos.arch=amd64
    gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.family=linux -Dos.arch=aarch64
    gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.name='Mac OS X' -Dos.arch=amd64
    gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.name='Mac OS X' -Dos.arch=aarch64
  '';

  # Gradle MITM + daemon need loopback IPC. Darwin sandbox treats Java
  # dual-stack ::ffff:127.0.0.1 as remote (NixOS/nix#11270). Unused on Linux.
  __darwinAllowLocalNetworking = true;
  sandboxProfile = lib.optionalString stdenv.hostPlatform.isDarwin ''
    (allow network-inbound (local ip "*:*"))
    (allow network-outbound (local ip "*:*"))
    (allow network-outbound (remote ip "*:*"))
    (allow network-outbound (remote ip6 "*:*"))
  '';

  env.JAVA_HOME = jdk21;
  env.JAVA_TOOL_OPTIONS = lib.optionalString stdenv.hostPlatform.isDarwin "-Djava.net.preferIPv4Stack=true";

  preConfigure = ''
    export ANDROID_USER_HOME="$TMPDIR/android"
    export GRADLE_USER_HOME="$TMPDIR/gradle"
  '';

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk21}"
    "-PskipAndroid=true"
    "-Dorg.gradle.native=false"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-Djava.net.preferIPv4Stack=true"
  ];

  nativeBuildInputs = [
    gradle_8
    jdk21
    copyDesktopItems
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    libxinerama
    libxrandr
    file
    gtk3
    glib
    cups
    lcms2
    alsa-lib
    libglvnd
  ];

  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "bifrost";
      exec = "Bifrost";
      icon = "bifrost";
      desktopName = "Bifrost";
      comment = "Samsung firmware downloader";
      categories = [ "Utility" ];
    })
  ];

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall

        mkdir -p $out/bin $out/libexec
        cp -a desktop/build/compose/binaries/main-release/app/Bifrost.app \
          $out/libexec/Bifrost.app

        install -D --mode=0644 desktop/src/jvmMain/resources/icon.png \
          $out/share/icons/hicolor/512x512/apps/bifrost.png

        makeWrapper $out/libexec/Bifrost.app/Contents/MacOS/Bifrost $out/bin/Bifrost

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mkdir -p $out/bin $out/opt/bifrost
        cp --recursive desktop/build/compose/binaries/main-release/app/Bifrost/* $out/opt/bifrost/
        rm -rf $out/opt/bifrost/lib/runtime
        ln -s ${jdk21}/lib/openjdk $out/opt/bifrost/lib/runtime
        install -D --mode=0644 $out/opt/bifrost/lib/Bifrost.png \
          $out/share/icons/hicolor/512x512/apps/bifrost.png

        makeWrapper $out/opt/bifrost/bin/Bifrost $out/bin/Bifrost \
          --prefix PATH : "${
            lib.makeBinPath (
              [
                glib
                dconf
                dpkg
                rpm
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [
                kreadconfig5Shim
                kdePackages.kconfig
              ]
            )
          }" \
          --set GSETTINGS_SCHEMA_DIR "${glib.getSchemaPath gsettings-desktop-schemas}" \
          --prefix XDG_DATA_DIRS : "${
            lib.makeSearchPath "share" [
              gsettings-desktop-schemas
              hicolor-icon-theme
              adwaita-icon-theme
            ]
          }" \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              stdenv.cc.cc.lib
              udev
              libglvnd
            ]
          }"

        runHook postInstall
      '';

  mitmCache = gradle_8.fetchDeps {
    inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
    silent = false;
    useBwrap = false;
  };

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-bifrost";
      runtimeInputs = [
        coreutils
        git
        nix
        nix-update
      ];
      text = ''
        set -euo pipefail

        nix-update bifrost
        updatePath="$(nix-build -A bifrost.mitmCache.updateScript --no-out-link)"
        "$updatePath"
      '';
    });
  };

  meta = {
    description = "Samsung firmware downloader";
    homepage = "https://github.com/zacharee/Bifrost";
    license = lib.licenses.mit;
    mainProgram = "Bifrost";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ mio ];
  };
})
