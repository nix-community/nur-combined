{
  _7zip-zstd,
  bash,
  customtkinter,
  desktop-file-utils,
  fetchFromGitHub,
  glib,
  gobject-introspection,
  lib,
  libloot-python,
  protontricks,
  python3Packages,
  wrapGAppsHook3,
  xdg-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amethyst-mod-manager";
  version = "1.3.13";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ChrisDKN";
    repo = "Amethyst-Mod-Manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KZkVv6AuG1joItUKlDyVmpkcgt/3gnQiSFKDs7ZDz7E=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=amethyst-mod-manager
  dependencies = [
    customtkinter
    libloot-python
  ]
  ++ (with python3Packages; [
    bsdiff4
    cryptography
    jeepney
    keyring
    lz4
    msgpack
    pillow
    py7zr
    pycairo
    pygobject3
    rarfile
    requests
    tkinter
    websocket-client
    zstandard
  ]);

  postPatch = ''
    substituteInPlace src/Nexus/nxm_handler.py \
        --replace-fail \
            "f'{cls._quote_if_needed(exe)} {cls._quote_if_needed(script)} --nxm %u'" \
            "'amethyst-mod-manager --nxm %u'"
  '';

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=amethyst-mod-manager
  installPhase = ''
    runHook preInstall

    pushd src > /dev/null
    find . -path "./appimage" -prune -o \
        -not -name "requirements*.txt" \
        -not -name "rebuild_libloot.sh" \
        -not -name "run.sh" \
        -not -name "loot.cpython*.so" \
        -type f \
        -exec install -Dm 755 '{}' "$out/${python3Packages.python.sitePackages}/{}" \;
    popd > /dev/null

    install -d $out/bin/

    echo "#!/bin/sh" > $out/bin/amethyst-mod-manager
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/gui.py \"\$@\"" >> $out/bin/amethyst-mod-manager
    chmod +x $out/bin/amethyst-mod-manager

    echo "#!/bin/sh" > "$out/bin/amethyst-mod-manager-cli"
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/cli.py \"\$@\"" >> $out/bin/amethyst-mod-manager-cli
    chmod +x $out/bin/amethyst-mod-manager-cli

    install -Dm644 flatpak/io.github.Amethyst.ModManager.desktop $out/share/applications/io.github.Amethyst.ModManager.desktop
    install -Dm644 src/appimage/mod-manager.png $out/share/icons/hicolor/512x512/apps/io.github.Amethyst.ModManager.png

    install -Dm644 Changelog.txt $out/${python3Packages.python.sitePackages}/Changelog.txt

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
        --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --suffix PATH : "${
          lib.makeBinPath [
            _7zip-zstd # 7z (fallback)
            bash
            desktop-file-utils # update-desktop-database
            glib # gio, gdbus
            protontricks
            python3Packages.python
            xdg-utils # xdg-open, xdg-mime, xdg-settings
          ]
        }"
    )
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
