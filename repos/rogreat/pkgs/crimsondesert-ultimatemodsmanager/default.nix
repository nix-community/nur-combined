{
  copyDesktopItems,
  fetchFromGitHub,
  imagemagick,
  lib,
  makeDesktopItem,
  privatebin,
  pyside6-fluent-widgets,
  python3Packages,
  rustPlatform,
  xvfb,
}:
let
  version = "3.3.21";
  src = fetchFromGitHub {
    owner = "faisalkindi";
    repo = "CrimsonDesert-UltimateModsManager";
    tag = "v${version}";
    hash = "sha256-uloma6dSkompW0xDIKGbOT7hkYbN4TFFh2jJUhgT79E=";
  };
  cdumm-native = python3Packages.buildPythonPackage (finalAttrs: {
    inherit src version;
    pname = "cdumm-native";
    pyproject = true;
    sourceRoot = "${src.name}/native";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      hash = "sha256-TVLNTlC2gKigeyyj09iH0MKOlmBIs6rCeeUHP+Nm3Ds=";
    };
    nativeBuildInputs = with rustPlatform; [
      cargoSetupHook
      maturinBuildHook
    ];
  });
in
python3Packages.buildPythonApplication (finalAttrs: {
  inherit src version;
  pname = "crimsondesert-ultimatemodsmanager";
  pyproject = true;

  build-system = with python3Packages; [
    setuptools
  ];

  pythonRemoveDeps = [
    "pyside6-essentials"
  ];

  dependencies = with python3Packages; [
    bsdiff4
    cdumm-native
    cryptography
    lxml
    lz4
    privatebin
    psutil
    py7zr
    pyside6
    pyside6-fluent-widgets
    websocket-client
    xxhash
  ];

  nativeCheckInputs = [
    xvfb
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-qt
    pytest-xvfb
  ]);

  disabledTestPaths = [
    # Fail
    "tests/test_script_import_consent_gate.py::test_script_import_runs_with_consent"
    # Slow
    "tests/test_f3_whole_table_growth.py"
    "tests/test_f3_whole_table_rebuild.py"
    "tests/test_iteminfo_cd110_layout.py"
    "tests/test_iteminfo_pabgh_companion.py"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "cdumm";
      desktopName = "CDUMM";
      genericName = "Mod Manager";
      comment = "Crimson Desert Ultimate Mods Manager";
      icon = "cdumm";
      exec = "cdumm";
      categories = [ "Utility" ];
    })
  ];

  prePatch = ''
    echo -e "#!/usr/bin/env python\n\n" > cdumm
    cat src/cdumm/main.py >> cdumm
    substituteInPlace cdumm \
        --replace-fail "Path(__file__).resolve().parents[2]" \
        "Path('$out/${python3Packages.python.sitePackages}').resolve()"

    substituteInPlace src/cdumm/engine/nxm_handler.py \
        --replace-fail "{exe} -m cdumm.main" "cdumm"
  '';

  postInstall = ''
    install -Dt $out/bin cdumm
    cp -a src/cdumm/translations $out/${python3Packages.python.sitePackages}/cdumm
    cp -a schemas $out/${python3Packages.python.sitePackages}
    cp -a field_schema $out/${python3Packages.python.sitePackages}

    for i in 16 24 48 64 96 128 256 512 1024; do
        mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
        magick assets/cdumm-logo.png -resize ''${i}x''${i}  \
            $out/share/icons/hicolor/''${i}x''${i}/apps/cdumm.png
    done
    cp -a assets $out/${python3Packages.python.sitePackages}
  '';

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
    )
  '';

  meta = {
    description = "Crimson Desert Ultimate Mods Manager";
    homepage = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cdumm";
    platforms = lib.platforms.linux;
  };
})
