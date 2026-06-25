{
  fetchFromGitHub,
  gobject-introspection,
  lib,
  libloot-python,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amethyst-mod-manager";
  version = "1.3.11";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ChrisDKN";
    repo = "Amethyst-Mod-Manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WqAYDCnzlpEWS+SXIpEGFw23yak7H0zgW4xqFAknRRQ=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=amethyst-mod-manager
  dependencies = [
    libloot-python
  ]
  ++ (with python3Packages; [
    bsdiff4
    cryptography
    customtkinter
    jeepney
    keyring
    lz4
    msgpack
    pillow
    py7zr
    pycairo
    rarfile
    requests
    tkinter
    websocket-client
    zstandard
  ]);

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=amethyst-mod-manager
  preInstall = ''
    pushd src > /dev/null
    find . -path "./appimage" -prune -o \
        -not -name "requirements*.txt" \
        -not -name "rebuild_libloot.sh" \
        -not -name "run.sh" \
        -not -name "loot.cpython*.so" \
        -type f \
        -exec install -Dm 755 '{}' "$out/${python3Packages.python.sitePackages}/{}" \;
    popd > /dev/null

    install -d "$out/bin/"

    echo "#!/bin/sh" > "$out/bin/amethyst-mod-manager"
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/gui.py \"\$@\"" >> "$out/bin/amethyst-mod-manager"
    chmod +x "$out/bin/amethyst-mod-manager"

    echo "#!/bin/sh" > "$out/bin/amethyst-mod-manager-cli"
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/cli.py \"\$@\"" >> "$out/bin/amethyst-mod-manager-cli"
    chmod +x "$out/bin/amethyst-mod-manager-cli"

    install -Dm644 "flatpak/io.github.Amethyst.ModManager.desktop" "$out/share/applications/io.github.Amethyst.ModManager.desktop"
    install -Dm644 "src/appimage/mod-manager.png" "$out/share/icons/hicolor/512x512/apps/io.github.Amethyst.ModManager.png"

    install -Dm644 LICENSE "$out/share/licenses/amethyst-mod-manager/LICENSE"
    install -Dm644 README.md "$out/share/doc/amethyst-mod-manager/README.md"
  '';

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        "''${gappsWrapperArgs[@]}"
        --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
    )
    wrapProgram $out/bin/amethyst-mod-manager ''${makeWrapperArgs[@]}
    wrapProgram $out/bin/amethyst-mod-manager-cli ''${makeWrapperArgs[@]}
  '';

  meta = {
    description = "Linux native mod manager for a variety of games";
    homepage = "https://github.com/ChrisDKN/Amethyst-Mod-Manager";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "amethyst-mod-manager";
    platforms = lib.platforms.linux;
  };
})
