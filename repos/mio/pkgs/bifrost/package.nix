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
    '';

    gradleBuildTask = ":desktop:createReleaseDistributable";
    gradleUpdateTask = finalAttrs.gradleBuildTask;

    mitmCache = gradle_8.fetchDeps {
      inherit (finalAttrs) pname;
      pkg = finalAttrs.finalPackage;
      data = ./deps.json;
      silent = false;
      useBwrap = false;
    };

    env.JAVA_HOME = jdk21;

    gradleFlags = [
      "-Dorg.gradle.java.home=${jdk21}"
    ];

    nativeBuildInputs = [
      gradle_8
      jdk21
      copyDesktopItems
      autoPatchelfHook
    ];

    buildInputs = [
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

    installPhase = ''
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
      platforms = lib.platforms.linux;
      maintainers = with lib.maintainers; [ onny ];
    };
  });

in
stdenv.mkDerivation {
  pname = "bifrost";
  inherit (bifrost-unwrapped) version;

  dontUnpack = true;

  installPhase = ''
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

  meta = bifrost-unwrapped.meta;
}
