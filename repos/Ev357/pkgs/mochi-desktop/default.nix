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
  version = "0.3.0-alpha.1";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "miflow13";
    repo = "mochi-desktop";
    rev = "535b520866b84d28f5755ef698a704c849ae1599";
    hash = "sha256-aRUnknk/4AStecTjVPWbFOsbwobAXVlyNoiWsbS8quk=";
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
