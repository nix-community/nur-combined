{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  jdk21,
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
  mesa,
  nspr,
  nss,
  pango,
  xorg,
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
    xorg.libX11
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-store";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "rainxchzed";
    repo = "Github-Store";
    rev = finalAttrs.version;
    hash = "sha256-FJ8GhDLfhHfDcctxUQENDYUjbrrfTQC6ZOsRkGKf/q0=";
  };

  patches = [
    ./skip-android.patch
    ./compose-repo.patch
  ];

  nativeBuildInputs = [
    gradle
    jdk21
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

    install -Dm644 composeApp/logo/app_icon.png \
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
