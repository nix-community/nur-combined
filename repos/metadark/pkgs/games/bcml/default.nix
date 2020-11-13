# TODO: Fix errors with Qt gui
# js: Uncaught TypeError: channel.execCallbacks[message.id] is not a function

{ gui
, enableUnfree ? false

  # Build dependencies
, lib
, pkgs
, nodejs
, stdenv
, callPackage
, makeDesktopItem
, python
, buildPythonApplication
, fetchFromGitHub
, mkdocs
, mkdocs-material

  # Runtime dependencies
, aamp
, botw-havok
, botw-utils
, byml
, oead
, pyyaml
, requests
, rstb
, xxhash
, p7zip

  # GTK dependencies
, gobject-introspection ? null
, webkitgtk ? null
, wrapGAppsHook ? null
, glib-networking ? null
, gst_all_1 ? null
, pygobject3 ? null

  # Qt dependencies
, wrapQtAppsHook ? null
, pyqt5 ? null
, pyqtwebengine ? null
}:

assert builtins.any (g: gui == g) [ "gtk" "qt" ];

assert gui == "gtk" -> gobject-introspection != null;
assert gui == "gtk" -> webkitgtk != null;
assert gui == "gtk" -> wrapGAppsHook != null;
assert gui == "gtk" -> glib-networking != null;
assert gui == "gtk" -> gst_all_1 != null;
assert gui == "gtk" -> pygobject3 != null;

assert gui == "qt" -> wrapQtAppsHook != null;
assert gui == "qt" -> pyqt5 != null;
assert gui == "qt" -> pyqtwebengine != null;

let
  guiName = {
    "gtk" = "GTK";
    "qt" = "Qt";
  }.${gui};

  js = (import ./js/node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  }).package;

  msyt = callPackage ./msyt { };

  desktopItem = makeDesktopItem {
    name = "bcml";
    exec = "bcml %u";
    icon = "bcml";
    desktopName = "BCML";
    genericName = "Mod Loader";
    comment = "A mod merging and managing tool for The Legend of Zelda: Breath of the Wild";
    categories = "Game;";
    mimeType = "x-scheme-handler/bcml;";
  };
in
buildPythonApplication rec {
  pname = "bcml";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "NiceneNerd";
    repo = pname;
    rev = "v${version}";
    sha256 = "0whzziin7h4n8g6dp5y2hr50avxjgrjv23xqh72x42c2678wpprc";
  };

  patches = [
    ./loosen-requirements.patch
    ./remove-register-handlers.patch
    ./remove-updater.patch
  ] ++ lib.optionals (gui == "gtk") [
    # Avoids errors printed trying to load Qt first
    ./prioritize-gtk.patch
  ];

  postPatch = ''
    # Patch in node_modules for building JS assets
    ln -s ${js}/lib/node_modules/js/node_modules bcml/assets

    # Remove prebuilt helper executables
    rm -rf bcml/helpers
  '';

  nativeBuildInputs = [
    mkdocs
    mkdocs-material
    nodejs
  ] ++ lib.optionals (gui == "gtk") [
    gobject-introspection
    webkitgtk
    wrapGAppsHook
  ] ++ lib.optionals (gui == "qt") [
    wrapQtAppsHook
  ];

  # Libraries for loading tutorial video in help
  buildInputs = lib.optionals (gui == "gtk") ([
    # TLS support for loading external HTTPS content in WebKitWebView
    glib-networking
  ] ++ (with gst_all_1; [
    # Audio & video support for WebKitWebView
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gstreamer
  ]));

  propagatedBuildInputs = [
    aamp
    botw-havok
    botw-utils
    byml
    oead
    pyyaml
    requests
    rstb
    xxhash
  ] ++ lib.optionals (gui == "gtk") [
    pygobject3
  ] ++ lib.optionals (gui == "qt") [
    pyqt5
    pyqtwebengine
  ];

  preBuild = ''
    (cd bcml/assets && npm run-script build)
    mkdocs build -d bcml/assets/help
  '';

  # No tests
  doCheck = false;

  # Prevent double wrapping
  dontWrapGApps = true;
  dontWrapQtApps = true;
  makeWrapperArgs =
    lib.optional (gui == "gtk") "\${gappsWrapperArgs[@]}"
    ++ lib.optional (gui == "qt") "\${qtWrapperArgs[@]}";

  postInstall = ''
    # Create desktop item
    mkdir -p "$out/share/applications"
    cp "${desktopItem}/share/applications/"* "$out/share/applications"

    # Link icon
    mkdir -p "$out/share/pixmaps"
    ln -s "$out/lib/python3.8/site-packages/bcml/data/logo.png" "$out/share/pixmaps/bcml.png"
  '';

  # Replace helper executables with nix-built equivalents
  preFixup = ''
    cd "$out/lib/${python.libPrefix}/site-packages/bcml"
    mkdir helpers && cd helpers
    ln -s ${msyt}/bin/msyt .
    ln -s ${p7zip.override { inherit enableUnfree; }}/bin/7z .
  '';

  meta = with lib; {
    description = "A mod merging and managing tool for The Legend of Zelda: Breath of the Wild (${guiName} GUI)";
    homepage = "https://github.com/NiceneNerd/BCML";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
