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

  pname = "aerion";
  version = current.version;

  versionFile = "pkgs/aerion/version.json";

  # Map Nix system names to upstream release asset architecture names.
  architectures = {
    x86_64-linux = "amd64";
    aarch64-linux = "arm64";
  };

  system = stdenv.hostPlatform.system;

  arch = architectures.${system} or (throw "aerion: unsupported system: ${system}");

  # Generate the upstream release archive URL.
  releaseBase = "https://github.com/hkdb/aerion/releases/download";

  urlFor =
    version: system:
    let
      assetArch = architectures.${system} or (throw "aerion: unsupported system: ${system}");
    in
    "${releaseBase}/v${version}/aerion-linux-${assetArch}.tar.gz";

  # Generate URL templates for all supported systems.
  hashUrls = lib.mapAttrs (system: _: urlFor "@VERSION@" system) architectures;

  # Fetch the latest upstream GitHub Release version.
  templateCommands = {
    VERSION = ''
      curl -fsSL \
        "https://api.github.com/repos/hkdb/aerion/releases/latest" |
        jq -er '.tag_name | ltrimstr("v")'
    '';
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  # Fetch and unpack the architecture-specific release archive.
  src = fetchzip {
    url = urlFor finalAttrs.version system;
    hash = current.${system + "-hash"};
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

  passthru.updateScript = callPackage ../../utils/update.nix {
    inherit pname versionFile;

    updateMethod = "none";

    fetchMetaCommand = lib.getExe (
      callPackage ../../utils/fetch-urls.nix {
        inherit versionFile templateCommands hashUrls;
        prefetchUnpack = true;
      }
    );
  };

  meta = {
    description = "A modern, cross-platform email client";
    homepage = "https://github.com/hkdb/aerion";
    license = lib.licenses.gpl3Only;
    platforms = builtins.attrNames architectures;
    mainProgram = "aerion";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
