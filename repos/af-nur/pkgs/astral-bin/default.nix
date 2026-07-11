{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, copyDesktopItems
, makeDesktopItem
, makeWrapper
, alsa-lib
, atk
, cairo
, curl
, gdk-pixbuf
, glib
, gtk3
, harfbuzz
, jdk
, libayatana-appindicator
, libGL
, libnotify
, libsecret
, libxkbcommon
, openssl
, pango
, sqlite
, webkitgtk_4_1
, zstd
,
}:

let
  runtimeLibraries = [
    alsa-lib
    atk
    cairo
    curl
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    jdk
    libayatana-appindicator
    libGL
    libnotify
    libsecret
    libxkbcommon
    openssl
    pango
    sqlite
    stdenv.cc.cc.lib
    webkitgtk_4_1
    zstd
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "astral-bin";
  version = "2.8.7";

  src = fetchurl {
    url = "https://github.com/ldoubil/astral/releases/download/v${finalAttrs.version}/astral-linux-x64.tar.gz";
    hash = "sha256-4FteYFCebhwoZsbLmId47PWMrJ/J27KMLRyQ2GzANt4=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = runtimeLibraries;

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/astral
    cp -r . $out/lib/astral

    install -Dm644 $out/lib/astral/data/flutter_assets/assets/logo.png \
      $out/share/icons/hicolor/512x512/apps/astral.png

    mkdir -p $out/bin
    makeWrapper $out/lib/astral/astral $out/bin/astral \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}:${jdk.home}/lib/server:$out/lib/astral/lib"

    runHook postInstall
  '';

  preFixup = ''
    addAutoPatchelfSearchPath ${jdk.home}/lib/server
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "astral";
      exec = "astral %U";
      icon = "astral";
      desktopName = "Astral";
      comment = "Cross-platform P2P network application based on EasyTier";
      categories = [ "Network" ];
    })
  ];

  meta = {
    description = "Cross-platform P2P network application based on EasyTier, prebuilt binary release";
    homepage = "https://github.com/ldoubil/astral";
    changelog = "https://github.com/ldoubil/astral/releases/tag/v${finalAttrs.version}";
    mainProgram = "astral";
    license = {
      shortName = "CC-BY-NC-ND-4.0";
      spdxId = "CC-BY-NC-ND-4.0";
      fullName = "Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International";
      url = "https://github.com/ldoubil/astral/blob/v${finalAttrs.version}/LICENSE";
      free = false;
      redistributable = true;
    };
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
