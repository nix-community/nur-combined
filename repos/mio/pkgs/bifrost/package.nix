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
  libsForQt5,
}:

let
  bifrost-unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "bifrost-unwrapped";
    version = "2.0.0";

    src = fetchFromGitHub {
      owner = "zacharee";
      repo = "SamloaderKotlin";
      tag = finalAttrs.version;
      hash = "sha256-AyWcq+dhp10aGmfW2VgMnc0crK5TForezkQGgPmKYyY=";
    };

    patches = [
      ./0001-fix-gradle-plugin-and-desktop-toolchain.patch
    ]
    ++ lib.optionals stdenv.isDarwin [
      ./0002-remove-foojay-resolver.patch
    ];

    postPatch = ''
      echo "kotlin.native.ignoreDisabledTargets=true" >> local.properties
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
      "-PskipAndroid=true"
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

        appdir="${bifrost-unwrapped}/Applications/Bifrost.app/Contents/app"
        cfg="$appdir/Bifrost.cfg"
        classpath=""
        main_class=""
        main_jar=""
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
            app.mainjar=*)
              main_jar="''${line#app.mainjar=}"
              main_jar="''${main_jar//\$APPDIR/$appdir}"
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

        if [ -n "$main_jar" ]; then
          if [ -z "$classpath" ]; then
            classpath="$main_jar"
          else
            classpath="$classpath:$main_jar"
          fi
        fi

        exec "${jdk21}/bin/java" \
          "''${java_opts[@]}" \
          -cp "$classpath" \
          "$main_class" \
          "$@"
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
          lib.makeBinPath (
            [
              glib
              dconf
              dpkg
              rpm
            ]
            ++ lib.optionals stdenv.isLinux [
              libsForQt5.kconfig
            ]
          )
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
