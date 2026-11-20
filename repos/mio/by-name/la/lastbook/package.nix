{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  makeWrapper,
  nixpkgs_pkgs,
  nix-update-script,
}:

# Lastbook is a plain-Python desktop app with its own native shell on each
# platform: GTK 3 + WebKitGTK 4.1 through PyGObject on Linux, AppKit/WKWebView
# through PyObjC on macOS. There is no Node/Electron build step.
#
# Platform packages are taken from nixpkgs_pkgs inside the Linux-only branches
# so that evaluating the package for Darwin does not require Linux packages
# (webkitgtk, GStreamer, Atk, X11) to exist in that package set.
let
  version = "1.1.13";

  src = fetchFromGitHub {
    owner = "Immortal-Protocols";
    repo = "lastbook";
    rev = "v${version}";
    hash = "sha256-cOBCGXanX9VidOtMTeJMzH+iEHH9iILjnMD6FS5soiQ=";
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
    map lib.getLib (
      with nixpkgs_pkgs;
      [
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
    )
  );

  # The codecs the library's videos need (H.264/AAC, WebM, AV1).
  gstPlugins = with nixpkgs_pkgs.gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];

  # Upstream pins llama.cpp b12032 for the runner; see ./llm-runner.nix.
  lastbook-llm = nixpkgs_pkgs.callPackage ./llm-runner.nix { inherit src version; };
in
stdenv.mkDerivation {
  pname = "lastbook";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals isLinux (
    with nixpkgs_pkgs;
    [
      pkg-config
      wrapGAppsHook3
    ]
  );

  buildInputs = lib.optionals isLinux (
    with nixpkgs_pkgs;
    [
      glib
      gtk3
      pango
      atk
      gdk-pixbuf
      libsoup_3
      webkitgtk_4_1
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
    ]
    ++ gstPlugins
  );

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

    # The local AI runner: llm_local.py looks for <app>/llm/lastbook-llm.
    cp -r ${lastbook-llm}/llm "$appdir/llm"

    install -Dm644 packaging/icon/tile-1024.png \
      $out/share/icons/hicolor/1024x1024/apps/lastbook.png

    ${lib.optionalString isLinux ''
      mkdir -p "$appdir/gst"
      install -m755 gst/libgstlastbooksrc.so "$appdir/gst/"

      substitute packaging/linux/lastbook.desktop lastbook.desktop \
        --replace-fail "/usr/bin/lastbook" "lastbook"
      install -Dm644 lastbook.desktop $out/share/applications/lastbook.desktop
    ''}

    # Run from source, not frozen: the packaged-app rules in shell_linux.py
    # strip GI_TYPELIB_PATH, which is how WebKitGTK is found here.
    cat > $out/bin/lastbook <<EOF
    #!${stdenv.shell}
    exec ${pythonEnv}/bin/python3 "$appdir/app/main.py" "\$@"
    EOF
    chmod +x $out/bin/lastbook

    # A real .app in $out/Applications, like nixpkgs' other macOS apps: the
    # keys mirror upstream's PyInstaller bundle (packaging/lastbook_macos.spec)
    # so the icon, name and the folder-access prompts are the same.
    ${lib.optionalString isDarwin ''
      appBundle="$out/Applications/Lastbook.app"
      mkdir -p "$appBundle/Contents/MacOS" "$appBundle/Contents/Resources"
      install -m644 packaging/Lastbook.icns "$appBundle/Contents/Resources/Lastbook.icns"

      cat > "$appBundle/Contents/Info.plist" <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleDisplayName</key>
        <string>Lastbook</string>
        <key>CFBundleExecutable</key>
        <string>Lastbook</string>
        <key>CFBundleIconFile</key>
        <string>Lastbook</string>
        <key>CFBundleIdentifier</key>
        <string>local.lastbook.desktop</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>Lastbook</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>${version}</string>
        <key>CFBundleVersion</key>
        <string>${version}</string>
        <key>LSApplicationCategoryType</key>
        <string>public.app-category.reference</string>
        <key>LSMinimumSystemVersion</key>
        <string>14.0</string>
        <key>LSRequiresNativeExecution</key>
        <true/>
        <key>NSHighResolutionCapable</key>
        <true/>
        <key>NSDesktopFolderUsageDescription</key>
        <string>Lastbook looks here for its library, the LastbookData folder. It reads and saves only inside that folder.</string>
        <key>NSDocumentsFolderUsageDescription</key>
        <string>Lastbook looks here for its library, the LastbookData folder. It reads and saves only inside that folder.</string>
        <key>NSDownloadsFolderUsageDescription</key>
        <string>Lastbook looks here for its library, the LastbookData folder. It reads and saves only inside that folder.</string>
      </dict>
      </plist>
      EOF

      ln -s "$out/bin/lastbook" "$appBundle/Contents/MacOS/Lastbook"
    ''}

    runHook postInstall
  '';

  # The gapps hook only applies gappsWrapperArgs, so wrap by hand: the
  # typelibs, our GStreamer source and the version the About screen shows.
  dontWrapGApps = true;
  preFixup =
    lib.optionalString isLinux ''
      wrapProgram $out/bin/lastbook \
        "''${gappsWrapperArgs[@]}" \
        --prefix GI_TYPELIB_PATH : "${typelibs}" \
        --prefix GST_PLUGIN_PATH_1_0 : "$out/share/lastbook/gst:${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}" \
        --set WEBKIT_GST_ALLOWED_URI_PROTOCOLS lastbook \
        --set LASTBOOK_VERSION ${version}
    ''
    + lib.optionalString isDarwin ''
      wrapProgram $out/bin/lastbook \
        --set LASTBOOK_VERSION ${version}
    '';

  passthru = {
    inherit lastbook-llm;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Offline survival library: guides, manuals, videos, maps and encyclopedias";
    homepage = "https://lastbook.org";
    license = lib.licenses.mit;
    mainProgram = "lastbook";
    # Upstream ships Linux x86_64/aarch64 and an Apple Silicon Mac build.
    platforms = lib.platforms.linux ++ [ "aarch64-darwin" ];
  };
}
