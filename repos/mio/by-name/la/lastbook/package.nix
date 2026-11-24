{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  pkg-config,
  wrapGAppsHook3,
  atk,
  cairo,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gst_all_1,
  gtk3,
  harfbuzz,
  libsoup_3,
  libx11,
  libxfixes,
  libxi,
  pango,
  webkitgtk_4_1,
  callPackage,
}:

# Lastbook is a plain-Python desktop app with its own native shell on each
# platform: GTK 3 + WebKitGTK 4.1 through PyGObject on Linux, AppKit/WKWebView
# through PyObjC on macOS. There is no Node/Electron build step.
let
  version = "1.1.17";

  src = fetchFromGitHub {
    owner = "Immortal-Protocols";
    repo = "lastbook";
    rev = "v${version}";
    hash = "sha256-aLHEoI5nha8j75AvExicuAVjWu2MB+ueFPabCGgQ6vs=";
  };

  isLinux = stdenv.hostPlatform.isLinux;
  isDarwin = stdenv.hostPlatform.isDarwin;

  python-libzim = python3.pkgs.callPackage ./python-libzim.nix { };

  pythonEnv = python3.withPackages (
    ps:
    [
      ps.beautifulsoup4
      ps.numpy
      ps.pypdfium2
      python-libzim
    ]
    ++ lib.optionals isLinux [ ps.pygobject3 ]
    ++ lib.optionals isDarwin [
      ps.pyobjc-core
      ps.pyobjc-framework-Cocoa
      ps.pyobjc-framework-WebKit
    ]
  );

  # Gtk's and WebKit's typelibs name their own dependencies (Pango names
  # HarfBuzz, GdkPixbuf names freetype/fontconfig, Gdk names X11, ...), so
  # the whole chain has to be on the path. Several only ship typelibs in
  # their lib output.
  typelibs = lib.makeSearchPath "lib/girepository-1.0" (
    map lib.getLib [
      glib
      gobject-introspection
      atk
      pango
      harfbuzz
      cairo
      freetype
      fontconfig
      gdk-pixbuf
      gtk3
      libx11
      libxfixes
      libxi
      libsoup_3
      webkitgtk_4_1
    ]
  );

  # The codecs the library's videos need (H.264/AAC, WebM, AV1).
  gstPlugins = [
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
  ];

  gstPluginPath = lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins;

  # Upstream pins llama.cpp b12032 for the runner; see ./llm-runner.nix.
  lastbook-llm = callPackage ./llm-runner.nix { inherit src version; };

  # The bundle keys and wording upstream's PyInstaller spec uses
  # (packaging/lastbook_macos.spec), so the icon, name and folder-access
  # prompts match the official Apple Silicon build.
  macFolderUsage = "Lastbook looks here for its library, the LastbookData folder. It reads and saves only inside that folder.";
  macInfoPlist = {
    CFBundleDevelopmentRegion = "en";
    CFBundleDisplayName = "Lastbook";
    CFBundleExecutable = "Lastbook";
    CFBundleIconFile = "Lastbook";
    CFBundleIdentifier = "local.lastbook.desktop";
    CFBundleInfoDictionaryVersion = "6.0";
    CFBundleName = "Lastbook";
    CFBundlePackageType = "APPL";
    CFBundleShortVersionString = version;
    CFBundleVersion = version;
    LSApplicationCategoryType = "public.app-category.reference";
    LSMinimumSystemVersion = "14.0";
    LSRequiresNativeExecution = true;
    NSDesktopFolderUsageDescription = macFolderUsage;
    NSDocumentsFolderUsageDescription = macFolderUsage;
    NSDownloadsFolderUsageDescription = macFolderUsage;
    NSHighResolutionCapable = true;
  };
in
stdenv.mkDerivation {
  pname = "lastbook";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals isLinux [
    copyDesktopItems
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals isLinux (
    [
      glib
      gtk3
      pango
      atk
      gdk-pixbuf
      libsoup_3
      webkitgtk_4_1
      gst_all_1.gstreamer
    ]
    ++ gstPlugins
  );

  desktopItems = lib.optionals isLinux [
    (makeDesktopItem {
      name = "lastbook";
      desktopName = "Lastbook";
      genericName = "Offline survival library";
      comment = "Search and read the survival library on this computer, with no internet";
      exec = "lastbook";
      icon = "lastbook";
      terminal = false;
      categories = [
        "Education"
        "Literature"
      ];
      keywords = [
        "survival"
        "library"
        "offline"
        "first aid"
      ];
      startupNotify = true;
      startupWMClass = "Lastbook";
    })
  ];

  buildPhase = lib.optionalString isLinux ''
    runHook preBuild

    # lastbooksrc lets WebKitGTK's GStreamer player open the app's own
    # lastbook:// video addresses; without it videos say they cannot play.
    mkdir -p gst
    $CC -shared -fPIC -O2 -Wall -Werror packaging/linux/gst/lastbooksrc.c \
      -o gst/libgstlastbooksrc.so \
      $(pkg-config --cflags --libs gstreamer-1.0 gstreamer-base-1.0)

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appdir=$out/share/lastbook
    mkdir -p $out/bin "$appdir"

    cp -r app engine web content "$appdir/"
    install -m644 server.py assistant.py retrieval.py llm_local.py "$appdir/"
    echo "${version}" > "$appdir/VERSION"

    # What setup can install: upstream's release builds bundle the manifest their
    # publishing pipeline writes (setup/manifest-v1.json, see
    # packaging/release_manifest.py). Without it the first screen has no library
    # or state to choose and the Start button stays disabled, because the copy
    # fetched while setup opens often times out.
    install -Dm644 ${./manifest-v1.json} "$appdir/setup/manifest-v1.json"

    # The local AI runner: llm_local.py looks for <app>/llm/lastbook-llm.
    cp -r ${lastbook-llm}/llm "$appdir/llm"

    install -Dm644 packaging/icon/tile-1024.png \
      $out/share/icons/hicolor/1024x1024/apps/lastbook.png

    ${lib.optionalString isLinux ''
      mkdir -p "$appdir/gst"
      install -m755 gst/libgstlastbooksrc.so "$appdir/gst/"
    ''}

    # Run from source, not frozen: the packaged-app rules in shell_linux.py
    # strip GI_TYPELIB_PATH, which is how WebKitGTK is found here.
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/lastbook \
      --add-flags "$appdir/app/main.py" \
      --set LASTBOOK_VERSION ${version}

    # A real .app in $out/Applications, like nixpkgs' other macOS apps.
    ${lib.optionalString isDarwin ''
      appBundle="$out/Applications/Lastbook.app"
      mkdir -p "$appBundle/Contents/MacOS" "$appBundle/Contents/Resources"
      install -m644 packaging/Lastbook.icns "$appBundle/Contents/Resources/Lastbook.icns"

      cat > "$appBundle/Contents/Info.plist" <<'EOF'
      ${lib.generators.toPlist { escape = true; } macInfoPlist}
      EOF

      ln -s "$out/bin/lastbook" "$appBundle/Contents/MacOS/Lastbook"
    ''}

    runHook postInstall
  '';

  # wrapGAppsHook3 wraps $out/bin/lastbook during fixup. These arguments add
  # what the hook cannot infer from buildInputs: the full typelib chain and
  # the app's own GStreamer source.
  preFixup = lib.optionalString isLinux ''
    gappsWrapperArgs+=(
      --prefix GI_TYPELIB_PATH : "${typelibs}"
      --prefix GST_PLUGIN_PATH_1_0 : "$out/share/lastbook/gst:${gstPluginPath}"
      --set WEBKIT_GST_ALLOWED_URI_PROTOCOLS lastbook
    )
  '';

  passthru = {
    inherit lastbook-llm;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Offline survival library: guides, manuals, videos, maps and encyclopedias";
    homepage = "https://lastbook.org";
    changelog = "https://github.com/Immortal-Protocols/lastbook/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "lastbook";
    # Upstream ships Linux x86_64/aarch64 and an Apple Silicon Mac build.
    platforms = lib.platforms.linux ++ [ "aarch64-darwin" ];
  };
}
