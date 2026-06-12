{
  copyDesktopItems,
  fetchFromGitHub,
  fetchpatch2,
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

  patches = [
    (fetchpatch2 {
      name = "unix-culprit-revert.patch";
      url = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager/commit/207453cd33bd5c185bbec278c3d4f9c2bca0776f.patch?full_index=1";
      hash = "sha256-fktQiZXLLlZvONnZaddlm/ss+l4Sb3umEaesyMr5Ofc=";
    })
    (fetchpatch2 {
      name = "unix-culprit-feat.patch";
      url = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager/commit/a17bc7ea0b22cbc33251156ca9f8edbee807e3ac.patch?full_index=1";
      hash = "sha256-9SRTklVwS6ysLQcPs/00FgoOt85RCYpQ2Y41trFG5ms=";
    })
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  pythonRemoveDeps = [
    "pyside6-essentials"
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

  postPatch = ''
    echo "#!/usr/bin/env python" > cdumm
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
