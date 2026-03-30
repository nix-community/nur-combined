{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  jdk21,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
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

let
  runtimeDeps = [
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
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-store";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "rainxchzed";
    repo = "Github-Store";
    rev = finalAttrs.version;
    hash = "sha256-/08WtOcoQ8T39kKo4J1NoT6YFIGlWz4WU9OVPL2bXxU=";
  };

  patches = [ ];

  postPatch = ''
    python - <<'PY'
    from pathlib import Path

    cmp = Path("build-logic/convention/src/main/kotlin/CmpApplicationConventionPlugin.kt")
    text = cmp.read_text()
    for old in [
        'import org.gradle.kotlin.dsl.dependencies\n',
        'import zed.rainxch.githubstore.convention.configureAndroidTarget\n',
        'import zed.rainxch.githubstore.convention.libs\n',
        '                apply("zed.rainxch.convention.android.application.compose")\n',
        '            configureAndroidTarget()\n',
        '\n            dependencies {\n                "debugImplementation"(libs.findLibrary("androidx-compose-ui-tooling").get())\n            }\n',
    ]:
        text = text.replace(old, "")
    cmp.write_text(text)

    app = Path("composeApp/build.gradle.kts")
    text = app.read_text()
    for old in [
        'android {\n    dependenciesInfo {\n        includeInApk = false\n        includeInBundle = false\n    }\n}\n\n',
        '        androidMain.dependencies {\n            implementation(libs.androidx.compose.ui.tooling.preview)\n            implementation(libs.androidx.activity.compose)\n\n            implementation(libs.core.splashscreen)\n\n            implementation(libs.koin.android)\n        }\n',
    ]:
        text = text.replace(old, "")
    app.write_text(text)

    settings = Path("settings.gradle.kts")
    text = settings.read_text()
    marker = '        mavenCentral()\n'
    replacement = '        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")\n' + marker
    text = text.replace(marker, replacement, 1)
    text = text.replace(marker, replacement, 1)
    settings.write_text(text)

    build_logic = Path("build-logic/settings.gradle.kts")
    text = build_logic.read_text()
    if "pluginManagement" not in text:
        text = text.replace(
            'rootProject.name = "build-logic"\n\n',
            'rootProject.name = "build-logic"\n\n'
            'pluginManagement {\n'
            '    repositories {\n'
            '        gradlePluginPortal()\n'
            '        google()\n'
            '        mavenCentral()\n'
            '    }\n'
            '}\n\n',
            1,
        )
    build_logic.write_text(text)
    PY
  '';

  nativeBuildInputs = [
    gradle
    jdk21
    python3
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = runtimeDeps;

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

  installPhase = ''
    runHook preInstall

    dist_root="$(find composeApp/build/compose/binaries -type d -path '*/main/app' -print | head -n1)"
    if [ -z "$dist_root" ]; then
      echo "Could not find compose distributable output" >&2
      exit 1
    fi

    app_dir="$(find "$dist_root" -mindepth 1 -maxdepth 1 -type d | head -n1)"
    if [ -z "$app_dir" ]; then
      echo "Could not find app directory in $dist_root" >&2
      exit 1
    fi

    mkdir -p $out/share/github-store
    cp -R "$app_dir"/* $out/share/github-store/

    install -Dm644 composeApp/src/jvmMain/resources/logo/app_icon.png \
      $out/share/icons/hicolor/512x512/apps/github-store.png

    bin_path="$(find $out/share/github-store/bin -maxdepth 1 -type f -perm -u+x -print | head -n1)"
    if [ -z "$bin_path" ]; then
      echo "Could not find app binary in $out/share/github-store/bin" >&2
      exit 1
    fi

    makeWrapper "$bin_path" "$out/bin/github-store" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDeps}" \
      --prefix XDG_DATA_DIRS : "$out/share"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "github-store";
      exec = "github-store";
      icon = "github-store";
      desktopName = "GitHub Store";
      comment = finalAttrs.meta.description;
      categories = [
        "Development"
      ];
    })
  ];

  meta = {
    description = "Cross-platform app store for GitHub releases";
    homepage = "https://github.com/rainxchzed/Github-Store";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "github-store";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
