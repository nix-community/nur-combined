{
  _7zz,
  bash,
  fetchFromGitHub,
  glib,
  lib,
  libloot-python,
  meson,
  ninja,
  protontricks,
  python3Packages,
  qt6,
  xdg-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amethyst-mod-manager";
  version = "2.0.5.beta-1";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "RoGreat";
    repo = "Amethyst-Mod-Manager";
    rev = "3ac3572a9445f229970a4cf2a6f85226b675c900";
    hash = "sha256-kxvQifoQo2AZs3gpAGeXVl5J5iIQz4Nz2RYrRUd5V+g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=amethyst-mod-manager
  dependencies = [
    libloot-python
  ]
  ++ (with python3Packages; [
    bsdiff4
    certifi
    cryptography
    jeepney
    keyring
    lz4
    msgpack
    pillow
    py7zr # fallback
    pyside6
    requests
    secretstorage
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
  postInstall = ''
    ln -s ${libloot-python}/${python3Packages.python.sitePackages}/loot/loot.cpython-314-x86_64-linux-gnu.so \
        $out/${python3Packages.python.sitePackages}/LOOT
  '';

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        "''${qtWrapperArgs[@]}"
        --suffix PATH : "${
          lib.makeBinPath [
            _7zz
            bash
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
