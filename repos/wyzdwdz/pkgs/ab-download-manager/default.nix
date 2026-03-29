{
  lib,
  stdenv,
  fetchgit,
  gradle,
  autoPatchelfHook,
  makeWrapper,
  libX11,
  libXrender,
  libXtst,
  fontconfig,
  harfbuzz,
  libGL,
  gtk3,
  vulkan-loader,
  libappindicator,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  version = "1.8.7";

  src = fetchgit {
    url = "https://github.com/amir1376/ab-download-manager.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YDARV3pbT8jvWuYthgKN+XxgJdDuZNbfqvfddKnp1Ls=";
  };

  nativeBuildInputs = [
    gradle
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libXrender
    libXtst
    fontconfig
    harfbuzz
    gtk3
    libGL
    vulkan-loader
    libappindicator
  ];

  enableParallelUpdating = false;
  enableParallelBuilding = false;

  postPatch = ''
    sed -i '/useFileSystemPermissions()/d' desktop/app/build.gradle.kts

    sed -i 's/from(tasks.named("createReleaseDistributable"))/dependsOn("createReleaseDistributable");from(project.layout.buildDirectory.dir("compose\/binaries\/main-release\/app"))/g' desktop/app/build.gradle.kts

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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/abdownloadmanager
    cp -r desktop/app/build/compose/binaries/main-release/app/ABDownloadManager/* $out/opt/abdownloadmanager/

    mkdir -p $out/bin
    makeWrapper $out/opt/abdownloadmanager/bin/ABDownloadManager $out/bin/ABDownloadManager \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"

    install -Dm644 desktop/app/icons/icon.png "$out/share/icons/hicolor/512x512/apps/abdownloadmanager.png"

    mkdir -p "$out/share/applications"
    substitute "${./abdownloadmanager.desktop}" "$out/share/applications/abdownloadmanager.desktop" \
        --replace-fail "Exec=/opt/abdownloadmanager/bin/ABDownloadManager" "Exec=$out/bin/ABDownloadManager" \
        --replace-fail "Icon=/usr/share/icons/hicolor/512x512/apps/abdownloadmanager.png" \
            "Icon=$out/share/icons/hicolor/512x512/apps/abdownloadmanager.png"

    runHook postInstall
  '';

  appendRunpaths = [ "${stdenv.cc.cc.lib}/lib" ];

  meta = with lib; {
    description = "A Download Manager that speeds up your downloads";
    homepage = "https://github.com/amir1376/ab-download-manager";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ABDownloadManager";
    broken = false;
  };
})
