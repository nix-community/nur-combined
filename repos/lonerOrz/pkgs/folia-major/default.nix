{
  lib,
  stdenv,
  fetchzip,
  callPackage,

  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,

  alsa-lib,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libglvnd,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libXtst,
  mesa,
  nss,
  zlib,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "folia-major-bin";
  version = current.version;

  runtimeDependencies = [
    alsa-lib
    fontconfig
    freetype
    glib
    gtk3
    libglvnd
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXScrnSaver
    libXtst
    mesa
    nss
    stdenv.cc.cc.lib
    zlib
  ];

  libraryPath = lib.makeLibraryPath runtimeDependencies;
in

stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchzip {
    url = "https://github.com/chthollyphile/folia-major/releases/download/v${finalAttrs.version}/folia-major-${finalAttrs.version}-linux-x64.tar.gz";
    hash = current."${stdenv.hostPlatform.system}-hash";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = runtimeDependencies;

  desktopItems = [
    (makeDesktopItem {
      name = "folia-major";
      desktopName = "Folia Major";
      exec = "folia-major";
      icon = "folia-major";
      categories = [
        "Audio"
        "Utility"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    appSourceDir=$(dirname "$(find . -type f -name 'folia-major' -perm -u+x | head -n1)")
    if [ -z "$appSourceDir" ]; then
      echo "Could not locate folia-major executable in source archive" >&2
      exit 1
    fi

    appdir=$out/lib/folia-major
    install -d $appdir
    cp -a "$appSourceDir"/. $appdir/

    install -Dm644 "$appSourceDir"/resources/icon.png \
      $out/share/icons/hicolor/512x512/apps/folia-major.png

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper \
      $out/lib/folia-major/folia-major \
      $out/bin/folia-major \
      --prefix LD_LIBRARY_PATH : "${libraryPath}" \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
      --add-flags "--enable-features=WaylandWindowDecorations"
  '';

  passthru.updateScript =
    let
      versionFile = "pkgs/folia-major/version.json";
    in
    callPackage ../../utils/update.nix {
      inherit versionFile;
      pname = "folia-major";
      updateMethod = "auto";
      fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubRelease {
        owner = "chthollyphile";
        repo = "folia-major";
      }}";
    };

  meta = {
    description = "Lyrics Reimagine desktop app packaged from prebuilt releases";
    homepage = "https://github.com/chthollyphile/folia-major";
    license = lib.licenses.agpl3Only;
    mainProgram = "folia-major";
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = [ "x86_64-linux" ];
  };
})
