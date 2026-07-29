{
  _7zz,
  bash,
  cabextract,
  fetchFromGitHub,
  git,
  glib,
  lib,
  libloot-python,
  meson,
  ninja,
  python3Packages,
  qt6,
  winetricks,
  xdg-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amethyst-mod-manager";
  version = "2.0.5";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ChrisDKN";
    repo = "Amethyst-Mod-Manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TR2dLZ+7gHSO8eosskCKg5JP9b/2MCZQingd3psFK8M=";
  };

  nativeBuildInputs = [
    git
    meson
    ninja
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
    patchShebangs src/version.py

    substituteInPlace src/Utils/protontricks.py \
        --replace-fail '_get_tools_dir() / "winetricks"' 'Path("${lib.getExe winetricks}")' \
        --replace-fail '_get_tools_dir() / "cabextract"' 'Path("${lib.getExe cabextract}")'

    substituteInPlace src/Nexus/nxm_handler.py \
        --replace-fail \
            "f'{cls._quote_if_needed(exe)} {cls._quote_if_needed(script)} --nxm %u'" \
            "'amethyst-mod-manager --nxm %u'"
  '';

  # no tests
  doCheck = false;

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --suffix PATH : "${
          lib.makeBinPath [
            # https://github.com/ChrisDKN/Amethyst-Mod-Manager/blob/main/flatpak/io.github.Amethyst.ModManager.yml
            _7zz
            bash
            glib # gio, gdbus
            python3Packages.python
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
