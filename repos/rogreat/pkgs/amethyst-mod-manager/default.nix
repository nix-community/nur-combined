{
  _7zz,
  appstream,
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
  version = "2.0.4";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "RoGreat";
    repo = "Amethyst-Mod-Manager";
    rev = "778bf63fb339950e412ef3afe91ec39e937c8c71";
    hash = "sha256-+7ptTCyRymLUvOl28ZykxnMbpBMn9Df8lKq4jPVbCuw=";
  };

  nativeBuildInputs = [
    appstream
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

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --set PATH "${
          lib.makeBinPath [
            # https://github.com/ChrisDKN/Amethyst-Mod-Manager/blob/main/flatpak/io.github.Amethyst.ModManager.yml
            _7zz
            cabextract
            python3Packages.python
            winetricks

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
