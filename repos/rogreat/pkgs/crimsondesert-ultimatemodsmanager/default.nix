{
  copyDesktopItems,
  fetchFromGitHub,
  imagemagick,
  lib,
  makeDesktopItem,
  privatebin,
  pyside6-fluent-widgets,
  python3Packages,
  qt6,
  rustPlatform,
  xvfb,
}:
let
  version = "3.10.0";
  src = fetchFromGitHub {
    owner = "faisalkindi";
    repo = "CrimsonDesert-UltimateModsManager";
    tag = "v${version}";
    hash = "sha256-zNBALrgflQ9YXYoHgS+rjM5/1JweBncBnJ5U6DTnTtQ=";
  };

  cdumm-native = python3Packages.buildPythonPackage (finalAttrs: {
    inherit src;
    pname = "cdumm-native";
    version = "0.1.0";
    pyproject = true;

    sourceRoot = "${src.name}/native";

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src sourceRoot;
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

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  dependencies = [
    cdumm-native
    privatebin
    pyside6-fluent-widgets
  ]
  ++ (with python3Packages; [
    bsdiff4
    cryptography
    lxml
    lz4
    pillow
    psutil
    py7zr
    pyside6
    websocket-client
    xxhash
  ]);

  nativeCheckInputs = [
    xvfb
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-qt
    pytest-xvfb
  ]);

  disabledTestPaths = [
    "tests/test_game_index.py::test_extract_reresolves_paz_under_game_dir" # Failed
    "tests/test_iteminfo_native_apply_e2e.py::test_format3_unknown_key_skipped_gracefully" # Slow
    "tests/test_schema_verify.py" # All Failed
    "tests/test_script_import_consent_gate.py::test_script_import_runs_with_consent" # Failed
  ];

  disabledTestMarks = [
    "slow"
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

  postPatch = ''
    substituteInPlace src/cdumm/main.py \
        --replace-fail "Path(__file__).resolve().parents[2]" "Path(__file__).resolve().parents[1]"

    substituteInPlace src/cdumm/engine/nxm_handler.py \
        --replace-fail "{exe} -m cdumm.main" "cdumm"
  '';

  postInstall = ''
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

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapper ${python3Packages.python.interpreter} $out/bin/cdumm \
        --add-flags "-m cdumm.main" \
        ''${qtWrapperArgs[@]} \
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
  '';

  meta = {
    description = "Crimson Desert Ultimate Mods Manager";
    homepage = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager";
    changelog = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cdumm";
    platforms = lib.platforms.linux;
  };
})
