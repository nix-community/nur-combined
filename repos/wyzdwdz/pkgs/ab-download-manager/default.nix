{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  libXrender,
  libXtst,
  fontconfig,
  harfbuzz,
  gtk3,
  libappindicator,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  version = "1.8.7";

  src = fetchFromGitHub {
    owner = "amir1376";
    repo = "ab-download-manager";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YDARV3pbT8jvWuYthgKN+XxgJdDuZNbfqvfddKnp1Ls=";
  };

  nativeBuildInputs = [
    gradle
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    libXrender
    libXtst
    fontconfig
    harfbuzz
    gtk3
    libappindicator
  ];

  postPatch = ''
    sed -i '/useFileSystemPermissions()/d' desktop/app/build.gradle.kts

    sed -i 's/from(tasks.named("createReleaseDistributable"))/dependsOn("createReleaseDistributable");from(project.layout.buildDirectory.dir("compose\/binaries\/main-release\/app"))/g' desktop/app/build.gradle.kts

    substituteInPlace build.gradle.kts \
        --replace-fail 'version = (gitVersion.getVersion() ?: fallBackVersion).toVersion()' \
        'version = "${finalAttrs.version}".toVersion()'

    cat >> build.gradle.kts <<'EOF'
    allprojects {
        repositories {
            maven { url = uri("https://maven.pkg.jetbrains.space/public/p/compose/dev") }
            maven { url = uri("https://www.jetbrains.com/intellij-repository/releases") }
            mavenCentral()
            google()
        }
    }
    EOF

    cat >> desktop/app/build.gradle.kts <<'EOF'
    tasks.register("nixFetchDependencies") {
        dependsOn("createReleaseDistributable")
        if (tasks.findByName("checkRuntime") != null) {
            dependsOn("checkRuntime")
        }
    }
    EOF

    cat > nix-kotlin-patch.gradle <<'EOF'
    allprojects {
        tasks.configureEach { task ->
            if (task.hasProperty("kotlinOptions")) {
                task.kotlinOptions.freeCompilerArgs += ["-Xskip-metadata-version-check"]
            }
        }
    }
    EOF
  '';

  # nix build .#ab-download-manager.mitmCache.updateScript && ./result
  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  gradleFlags = [
    "-Dfile.encoding=utf-8"
    "--init-script=nix-kotlin-patch.gradle"
  ];

  gradleBuildTask = ":desktop:app:createReleaseDistributable";
  gradleUpdateTask = ":desktop:app:nixFetchDependencies";

  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "abdownloadmanager";
      exec = "ABDownloadManager";
      icon = "abdownloadmanager";
      desktopName = "AB Download Manager";
      comment = "Manage and organize your download files better than before";
      categories = [
        "Utility"
        "Network"
      ];
      startupWMClass = "com-abdownloadmanager-desktop-AppKt";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/abdownloadmanager
    cp -r desktop/app/build/compose/binaries/main-release/app/ABDownloadManager/* $out/opt/abdownloadmanager/

    mkdir -p $out/bin
    ln -s $out/opt/abdownloadmanager/bin/ABDownloadManager $out/bin/ABDownloadManager

    install -Dm644 desktop/app/icons/icon.png "$out/share/icons/hicolor/512x512/apps/abdownloadmanager.png"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Download Manager that speeds up your downloads";
    homepage = "https://github.com/amir1376/ab-download-manager";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
    mainProgram = "ABDownloadManager";
    broken = false;
  };
})
