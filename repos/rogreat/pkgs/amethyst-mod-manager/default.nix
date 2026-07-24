{
  _7zz,
  bash,
  cabextract,
  fetchFromGitHub,
  glib,
  lib,
  libloot-python,
  python3Packages,
  qt6,
  winetricks,
  xdg-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amethyst-mod-manager";
  version = "2.0.4";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ChrisDKN";
    repo = "Amethyst-Mod-Manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z6T4aqUkFZC8Ihb26lovqzDJRQYD6H9Gna3x1OzRhLA=";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  dependencies = [
    libloot-python
  ]
  ++ (with python3Packages; [
    # https://github.com/ChrisDKN/Amethyst-Mod-Manager/blob/main/src/requirements-vendor.txt
    pyside6
    py7zr
    pillow
    lz4
    zstandard
    requests
    websocket-client
    keyring
    jeepney
    msgpack
    bsdiff4
  ]);

  postPatch = ''
    substituteInPlace src/LOOT/eligibility.py src/LOOT/loot_sorter.py \
        --replace-fail 'import LOOT.loot as loot' 'import loot'

    substituteInPlace src/Utils/protontricks.py \
        --replace-fail '_get_tools_dir() / "winetricks"' 'Path("${lib.getExe winetricks}")' \
        --replace-fail '_get_tools_dir() / "cabextract"' 'Path("${lib.getExe cabextract}")'

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
        -not -name "run_qt.sh" \
        -not -name "loot.cpython*.so" \
        -type f \
        -exec install -Dm 755 '{}' "$out/${python3Packages.python.sitePackages}/{}" \;
    popd > /dev/null

    install -d $out/bin/

    echo "#!/bin/sh" > $out/bin/amethyst-mod-manager
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/run_qt.py \"\$@\"" >> $out/bin/amethyst-mod-manager
    chmod +x $out/bin/amethyst-mod-manager

    echo "#!/bin/sh" > "$out/bin/amethyst-mod-manager-cli"
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/cli.py \"\$@\"" >> $out/bin/amethyst-mod-manager-cli
    chmod +x $out/bin/amethyst-mod-manager-cli

    install -Dm644 flatpak/io.github.Amethyst.ModManager.desktop $out/share/applications/io.github.Amethyst.ModManager.desktop
    install -Dm644 src/appimage/mod-manager.png $out/share/icons/hicolor/256x256/apps/io.github.Amethyst.ModManager.png

    install -Dm644 Changelog.txt $out/${python3Packages.python.sitePackages}/Changelog.txt

    runHook postInstall
  '';

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --set PATH "${
          lib.makeBinPath [
            # https://github.com/ChrisDKN/Amethyst-Mod-Manager/blob/main/flatpak/io.github.Amethyst.ModManager.yml
            _7zz
            bash
            cabextract
            glib # gio, gdbus
            python3Packages.python
            winetricks
            xdg-utils # xdg-open, xdg-mime, xdg-settings
          ]
        }"
    )
    wrapQtApp $out/bin/amethyst-mod-manager ''${makeWrapperArgs[@]}
    wrapProgram $out/bin/amethyst-mod-manager-cli ''${makeWrapperArgs[@]}
  '';

  meta = {
    description = "Linux native mod manager for a variety of games";
    homepage = "https://github.com/ChrisDKN/Amethyst-Mod-Manager";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "amethyst-mod-manager";
    platforms = [ "x86_64-linux" ];
  };
})
