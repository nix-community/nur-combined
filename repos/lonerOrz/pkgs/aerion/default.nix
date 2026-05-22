{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  wrapGAppsHook4,
  callPackage,

  gtk3,
  glib,
  gdk-pixbuf,
  cairo,
  pango,
  atk,
  webkitgtk_4_1,
  libsoup_3,
}:

let
  current = lib.trivial.importJSON ./version.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "aerion";
  version = current.version;

  src =
    let
      system = stdenv.hostPlatform.system;
      hashKey = "${system}-hash";
      hash = current.${hashKey} or (throw "Unsupported system: ${system}");
    in
    fetchzip {
      url = "https://github.com/hkdb/aerion/releases/download/v${finalAttrs.version}/aerion-linux-${if system == "x86_64-linux" then "amd64" else "arm64"}.tar.gz";
      inherit hash;
      stripRoot = false;
    };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    atk
    webkitgtk_4_1
    libsoup_3
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "io.github.hkdb.Aerion";
      desktopName = "Aerion";
      genericName = "Email";
      comment = "A modern, cross-platform email client";

      exec = "aerion %U";
      icon = "io.github.hkdb.Aerion";

      terminal = false;
      startupNotify = true;
      startupWMClass = "Aerion";

      categories = [
        "Network"
        "Email"
      ];

      mimeTypes = [
        "x-scheme-handler/mailto"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 aerion $out/bin/aerion

    install -Dm644 \
      io.github.hkdb.Aerion.png \
      $out/share/icons/hicolor/256x256/apps/io.github.hkdb.Aerion.png

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/aerion \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          gtk3
          glib
          gdk-pixbuf
          cairo
          pango
          atk
          webkitgtk_4_1
          libsoup_3
        ]
      }
  '';

  passthru.updateScript =
    let
      versionFile = "pkgs/aerion/version.json";
    in
    callPackage ../../utils/update.nix {
      inherit versionFile;
      pname = "aerion";
      updateMethod = "none";
      fetchMetaCommand = "${lib.getExe (
        callPackage ../../utils/fetch-urls.nix {
          inherit versionFile;
          versionCommand = ''
            curl -sS https://api.github.com/repos/hkdb/aerion/releases/latest \
              | jq -r '.tag_name | ltrimstr("v")'
          '';
          hashUrls = {
            x86_64-linux = "https://github.com/hkdb/aerion/releases/download/v$VERSION/aerion-linux-amd64.tar.gz";
            aarch64-linux = "https://github.com/hkdb/aerion/releases/download/v$VERSION/aerion-linux-arm64.tar.gz";
          };
          prefetchUnpack = true;
        }
      )}";
    };

  meta = {
    description = "A modern, cross-platform email client";
    homepage = "https://github.com/hkdb/aerion";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "aerion";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})