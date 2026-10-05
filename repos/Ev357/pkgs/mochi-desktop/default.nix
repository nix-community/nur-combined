{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  adwaita-icon-theme,
  gobject-introspection,
  gtk4,
  gtk4-layer-shell,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication rec {
  pname = "mochi-desktop";
  version = "archive/2026-09-08/prebaseline-main";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "miflow13";
    repo = "mochi-desktop";
    rev = "8ac1478e064673657c4206e2a20d6024bb026291";
    hash = "sha256-Y8tfUE7nlpoCujOa6GpTrid9ymFUw4jtdepsFyN4vIk=";
  };

  patches = [
    ./layer-shell-menu.patch
  ];

  postPatch = ''
    substituteInPlace src/mochi/sprite_loader.py \
      --replace-fail 'Path(sys.prefix) / "share" / "mochi" / "manifest.json",' 'Path(__file__).resolve().parents[4] / "share" / "mochi" / "manifest.json", Path(sys.prefix) / "share" / "mochi" / "manifest.json",'
    substituteInPlace src/mochi/sound.py \
      --replace-fail 'Path(sys.prefix) / "share" / "mochi" / "audio",' 'Path(__file__).resolve().parents[4] / "share" / "mochi" / "audio", Path(sys.prefix) / "share" / "mochi" / "audio",'
    substituteInPlace src/mochi/presence/feeding.py \
      --replace-fail '"emblem-favorite-symbolic"' '"starred-symbolic"'
    substituteInPlace src/mochi/buddy_menu.py \
      --replace-fail '"emblem-favorite-symbolic"' '"starred-symbolic"'
    substituteInPlace src/mochi/presence/bond_meter.py \
      --replace-fail '"emblem-favorite-symbolic"' '"starred-symbolic"'
  '';

  build-system = [
    python3Packages.setuptools
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    adwaita-icon-theme
    gtk4
    gtk4-layer-shell
  ];

  dependencies = [
    python3Packages.pycairo
    python3Packages.pygobject3
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [gtk4-layer-shell]}"
      --prefix LD_PRELOAD : "${gtk4-layer-shell}/lib/libgtk4-layer-shell.so"
    )
  '';

  pythonImportsCheck = [
    "mochi"
    "mochi.app"
    "mochi.sound"
    "mochi.sprites"
  ];

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "A cute, lightweight desktop companion for Linux that idles, reacts, sleeps, and hangs out while you work";
    homepage = "https://github.com/miflow13/mochi-desktop";
    changelog = "https://github.com/miflow13/mochi-desktop/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "mochi";
  };
}
