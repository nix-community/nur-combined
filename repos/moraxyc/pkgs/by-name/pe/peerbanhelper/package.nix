{
  lib,
  stdenvNoCC,
  callPackage,
  copyDesktopItems,
  gradle_9,
  jdk25,
  jdk25_headless,
  makeDesktopItem,
  makeWrapper,
  udev,

  pbhJdk ? if withGui then jdk25 else jdk25_headless,
  pbhGradle ? gradle_9,

  withGui ? true,

  sources,
  source ? sources.peerbanhelper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  nativeBuildInputs = [
    pbhGradle
    makeWrapper
  ]
  ++ lib.optional withGui copyDesktopItems;

  mitmCache = pbhGradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = source.gradleDeps;
  };

  gradleBuildTask = "jar";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  gradleFlags = [
    "-Dorg.gradle.java.home=${pbhJdk.home}"
    "-x"
    "generateGitProperties"
  ];

  postPatch = ''
    substituteInPlace settings.gradle.kts \
      --replace-fail 'id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"' ""

    cat > src/main/resources/git.properties <<EOF
    git.build.version=${finalAttrs.version}
    git.branch=release
    git.commit.id=${finalAttrs.src.rev or finalAttrs.version}
    git.commit.id.abbrev=${builtins.substring 0 7 (finalAttrs.src.rev or finalAttrs.version)}
    EOF
  '';

  preBuild = lib.optionalString (finalAttrs.mitmCache != "") ''
    rm -rf src/main/resources/static
    cp -r ${finalAttrs.passthru.webui} src/main/resources/static
    chmod -R u+w src/main/resources/static
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/peerbanhelper
    cp build/libs/PeerBanHelper.jar $out/share/peerbanhelper/
    cp -r build/libraries $out/share/peerbanhelper/

    makeWrapper ${lib.getExe pbhJdk} $out/bin/peerbanhelper \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]} \
      --set-default PBH_USEPLATFORMCONFIGLOCATION true ${
        lib.optionalString (!withGui) "--set-default PBH_NOGUI true"
      } \
      --add-flags "--enable-native-access=ALL-UNNAMED" \
      --add-flags "-XX:+UseCompactObjectHeaders" \
      --add-flags "-XX:-UseBASE64Intrinsics" \
      --add-flags "-XX:SoftMaxHeapSize=386M" \
      --add-flags "-XX:MaxRAMPercentage=85.0" \
      --add-flags "-XX:+UseG1GC" \
      --add-flags "-XX:G1PeriodicGCInterval=60000" \
      --add-flags "-XX:MaxHeapFreeRatio=15" \
      --add-flags "-XX:MinHeapFreeRatio=5" \
      --add-flags "-Xss512k" \
      --add-flags "-XX:+UseStringDeduplication" \
      --add-flags "-XX:-ShrinkHeapInSteps" \
      --add-flags "-Djdk.attach.allowAttachSelf=true" \
      --add-flags "-Dsun.net.useExclusiveBind=false" \
      --add-flags "-Dpbh.release=nix" \
      --add-flags "-Dfile.encoding=UTF-8" \
      --add-flags "-Dstdout.encoding=UTF-8" \
      --add-flags "-Dstderr.encoding=UTF-8" \
      --add-flags "-Dconsole.encoding=UTF-8" \
      --add-flags "-jar $out/share/peerbanhelper/PeerBanHelper.jar"
  ''
  + lib.optionalString withGui ''
    install -Dm644 src/main/resources/assets/icon.png $out/share/icons/hicolor/256x256/apps/peerbanhelper.png
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = lib.optional withGui (makeDesktopItem {
    name = "peerbanhelper";
    desktopName = "PeerBanHelper";
    genericName = "BitTorrent Anti-Leech Tool";
    comment = finalAttrs.meta.description;
    exec = "peerbanhelper";
    icon = "peerbanhelper";
    categories = [
      "Network"
      "P2P"
    ];
    startupWMClass = "com-ghostchu-peerbanhelper-MainJumpLoader";
  });

  passthru = {
    webui = callPackage ./webui.nix {
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };
  };

  meta = {
    description = "Automatically block unwanted, leeches and abnormal BT peers with support for customized and cloud rules";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    changelog = "https://github.com/PBH-BTN/PeerBanHelper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "peerbanhelper";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  };
})
