{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  jdk21,
  fontconfig,
  libXinerama,
  libXrandr,
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
  autoPatchelfHook,
  writeShellApplication,
  nix-update,
  git,
  nix,
  coreutils,
  findutils,
}:

let
  bifrost-unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "bifrost-unwrapped";
    version = "1.20.4";

    src = fetchFromGitHub {
      owner = "zacharee";
      repo = "SamloaderKotlin";
      tag = finalAttrs.version;
      hash = "sha256-fADiOJ1J/3QTWC6+e09apbpJWY+iWdV+olRLQIOtf5Q=";
    };

    postPatch = ''
      echo "kotlin.native.ignoreDisabledTargets=true" >> local.properties
      substituteInPlace desktop/build.gradle.kts \
        --replace-fail "this.vendor.set(JvmVendorSpec.MICROSOFT)" ""
      substituteInPlace gradle/libs.versions.toml \
        --replace-fail 'windowStyler = "0.3.3-20250226.143418-11"' \
                       'windowStyler = "0.3.2"'
      substituteInPlace common/build.gradle.kts \
        --replace-fail '    alias(libs.plugins.android.library)' \
                       '    alias(libs.plugins.android.library) apply false' \
        --replace-fail '    alias(libs.plugins.moko.resources)
}

' \
                       '    alias(libs.plugins.moko.resources)
}

val skipAndroid = project.hasProperty("skipAndroid")
if (!skipAndroid) {
    apply(plugin = "com.android.library")
}

' \
        --replace-fail $'    androidTarget {\n' \
                       $'    if (!skipAndroid) {\n        androidTarget {\n' \
        --replace-fail $'    }\n\n    jvm {\n' \
                       $'    }\n    }\n\n    jvm {\n' \
        --replace-fail $'        val androidMain by getting {\n            dependsOn(androidAndJvmMain)\n\n            dependencies {\n                api(libs.androidx.activity.compose)\n                api(libs.androidx.core.ktx)\n                api(libs.androidx.documentfile)\n                api(libs.androidx.preference.ktx)\n                api(libs.bugsnag.android)\n                api(libs.google.material)\n                api(libs.kotlinx.coroutines.android)\n                api(libs.github.api)\n            }\n        }\n' \
                       $'        if (!skipAndroid) {\n            val androidMain by getting {\n                dependsOn(androidAndJvmMain)\n\n                dependencies {\n                    api(libs.androidx.activity.compose)\n                    api(libs.androidx.core.ktx)\n                    api(libs.androidx.documentfile)\n                    api(libs.androidx.preference.ktx)\n                    api(libs.bugsnag.android)\n                    api(libs.google.material)\n                    api(libs.kotlinx.coroutines.android)\n                    api(libs.github.api)\n                }\n            }\n        }\n' \
        --replace-fail $'android {\n' \
                       $'plugins.withId(\"com.android.library\") {\n    extensions.configure<com.android.build.gradle.LibraryExtension>(\"android\") {\n' \
        --replace-fail $'}\n\nbuildkonfig {\n' \
                       $'}\n}\n\nbuildkonfig {\n' \
        --replace-fail $'dependencies {\n    coreLibraryDesugaring(libs.desugar.jdk.libs)\n}\n' \
                       $'plugins.withId(\"com.android.library\") {\n    dependencies {\n        add(\"coreLibraryDesugaring\", libs.desugar.jdk.libs)\n    }\n}\n'
      substituteInPlace settings.gradle.kts \
        --replace-fail '        maven("https://s01.oss.sonatype.org/content/repositories/snapshots/")' "" \
        --replace-fail 'include(":android")' \
                       $'if (!providers.gradleProperty("skipAndroid").isPresent) {\n    include(\":android\")\n}'
    ''
    + lib.optionalString stdenv.isDarwin ''
      substituteInPlace settings.gradle.kts \
        --replace-fail 'id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"' \
                       ""
    '';

    gradleBuildTask = ":desktop:createReleaseDistributable";
    gradleUpdateTask = finalAttrs.gradleBuildTask;

    gradleUpdateScript = ''
      runHook preBuild

      gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.family=linux -Dos.arch=amd64
      gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.family=linux -Dos.arch=aarch64
      gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.name='Mac OS X' -Dos.arch=amd64
      gradle :desktop:nixDownloadDeps -PskipAndroid=true -Dos.name='Mac OS X' -Dos.arch=aarch64
    '';

    mitmCache = gradle_8.fetchDeps {
      inherit (finalAttrs) pname;
      pkg = finalAttrs.finalPackage;
      data = ./deps.json;
      silent = false;
      useBwrap = false;
    };

    env.JAVA_HOME = jdk21;
    env.ANDROID_USER_HOME = "$TMPDIR/android";
    env.GRADLE_USER_HOME = "$TMPDIR/gradle";

    gradleFlags = [
      "-Dorg.gradle.java.home=${jdk21}"
    ];

    nativeBuildInputs = [
      gradle_8
      jdk21
      copyDesktopItems
    ]
    ++ lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ];

    buildInputs = lib.optionals stdenv.isLinux [
      fontconfig
      libXinerama
      libXrandr
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
      if stdenv.isDarwin then
        ''
          runHook preInstall

          mkdir -p $out/Applications
          cp --recursive desktop/build/compose/binaries/main-release/app/Bifrost.app \
            $out/Applications/Bifrost.app

          runHook postInstall
        ''
      else
        ''
          runHook preInstall

          cp --recursive desktop/build/compose/binaries/main-release/app/Bifrost $out
          install -D --mode=0644 $out/lib/Bifrost.png \
            $out/share/icons/hicolor/512x512/apps/bifrost.png

          runHook postInstall
        '';

    meta = {
      description = "Samsung firmware downloader";
      homepage = "https://github.com/zacharee/SamloaderKotlin";
      license = lib.licenses.mit;
      mainProgram = "Bifrost";
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryBytecode
      ];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      maintainers = with lib.maintainers; [ ];
    };
  });

in
stdenv.mkDerivation {
  pname = "bifrost";
  inherit (bifrost-unwrapped) version;

  dontUnpack = true;

  installPhase =
    if stdenv.isDarwin then
      ''
        runHook preInstall

        mkdir -p $out/bin $out/Applications
        ln -s ${bifrost-unwrapped}/Applications/Bifrost.app \
          $out/Applications/Bifrost.app
        cat > $out/bin/Bifrost <<'EOF'
        #!/usr/bin/env bash
        set -euo pipefail
        exec "${bifrost-unwrapped}/Applications/Bifrost.app/Contents/MacOS/Bifrost" "$@"
        EOF
        chmod +x $out/bin/Bifrost

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mkdir -p $out/bin
        cat > $out/bin/Bifrost <<'EOF'
        #!/usr/bin/env bash
        set -euo pipefail

        appdir="${bifrost-unwrapped}/lib/app"
        cfg="$appdir/Bifrost.cfg"
        classpath=""
        main_class=""
        java_opts=()

        while IFS= read -r line; do
          case "$line" in
            app.classpath=*)
              entry="''${line#app.classpath=}"
              entry="''${entry//\$APPDIR/$appdir}"
              if [ -z "$classpath" ]; then
                classpath="$entry"
              else
                classpath="$classpath:$entry"
              fi
              ;;
            app.mainclass=*)
              main_class="''${line#app.mainclass=}"
              ;;
            java-options=*)
              opt="''${line#java-options=}"
              opt="''${opt//\$APPDIR/$appdir}"
              java_opts+=("$opt")
              ;;
          esac
        done < "$cfg"

        if [ -z "$main_class" ]; then
          echo "Missing main class in $cfg" >&2
          exit 1
        fi

        export PATH="${
          lib.makeBinPath [
            glib
            dconf
            dpkg
            rpm
          ]
        }:$PATH"
        export GSETTINGS_SCHEMA_DIR="${glib.getSchemaPath gsettings-desktop-schemas}"
        export XDG_DATA_DIRS="${
          lib.makeSearchPath "share" [
            gsettings-desktop-schemas
            hicolor-icon-theme
            adwaita-icon-theme
          ]
        }:''${XDG_DATA_DIRS:-}"
        export LD_LIBRARY_PATH="${
          lib.makeLibraryPath [
            stdenv.cc.cc.lib
            udev
            libglvnd
          ]
        }:''${LD_LIBRARY_PATH:-}"
        export JAVA_HOME="${jdk21}"

        exec "${jdk21}/bin/java" \
          "''${java_opts[@]}" \
          -cp "$classpath" \
          "$main_class"
        EOF
        chmod +x $out/bin/Bifrost

        ln -s ${bifrost-unwrapped}/share $out/share
        ln -s ${bifrost-unwrapped}/lib $out/lib

        runHook postInstall
      '';

  passthru.unwrapped = bifrost-unwrapped;
  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-bifrost";
    runtimeInputs = [
      coreutils
      findutils
      git
      nix
      nix-update
    ];
    text = ''
      set -euo pipefail

      nix-update bifrost-unwrapped
      updatePath="$(nix build .#bifrost-unwrapped.mitmCache.updateScript --no-link --print-out-paths)"
      if [ -x "$updatePath" ]; then
        "$updatePath"
      elif [ -d "$updatePath"/bin ]; then
        updateScript="$(find "$updatePath"/bin -maxdepth 1 -type f -name '*update*' | head -n 1 || true)"
        if [ -n "$updateScript" ]; then
          "$updateScript"
        fi
      fi
    '';
  });

  meta = bifrost-unwrapped.meta;
}
