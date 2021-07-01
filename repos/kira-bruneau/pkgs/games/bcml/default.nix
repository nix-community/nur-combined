# TODO: Fix errors with Qt gui
# js: Uncaught TypeError: channel.execCallbacks[message.id] is not a function

{ gui

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
, autoPatchelfHook
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
, gobject-introspection
, webkitgtk
, wrapGAppsHook
, glib-networking
, gst_all_1
, pygobject3

  # Qt dependencies
, wrapQtAppsHook
, pyqt5
, pyqtwebengine
}:

assert builtins.any (g: gui == g) [ "gtk" "qt" ];

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
  version = "3.4.9";

  src = fetchFromGitHub {
    owner = "NiceneNerd";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2/UlsVqOOe77lCVQjrTh0hhzP+reePlWnvJ81QYm9O0=";
  };

  patches = [
    ./dont-modify-helpers.patch
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
  '';

  nativeBuildInputs = [
    autoPatchelfHook
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
  buildInputs = [
    stdenv.cc.cc
  ] ++ lib.optionals (gui == "gtk") ([
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
  pythonImportsCheck = [ "bcml" ];

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

  meta = with lib; {
    description = "A mod merging and managing tool for The Legend of Zelda: Breath of the Wild (${guiName} GUI)";
    homepage = "https://github.com/NiceneNerd/BCML";
    # Unfree due to 7zip's non-free UnRAR license restriction
    # Would be gpl3Plus without the restriction
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    broken = true; # oead references commit outside of branch
  };
}
