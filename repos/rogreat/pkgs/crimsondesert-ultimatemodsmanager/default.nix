{
  copyDesktopItems,
  fetchFromGitHub,
  fetchPypi,
  fetchpatch2,
  imagemagick,
  lib,
  makeDesktopItem,
  python3Packages,
  rustPlatform,
  xvfb,
}:
let
  version = "3.3.12";
  src = fetchFromGitHub {
    owner = "faisalkindi";
    repo = "CrimsonDesert-UltimateModsManager";
    tag = "v${version}";
    hash = "sha256-4894imPo4pRaczuuxIdmRX9JmoS7nz6F1Zz6yXNYBBE=";
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

  pysidesix-frameless-window = python3Packages.buildPythonPackage (finalAttrs: {
    pname = "pysidesix-frameless-window";
    version = "0.8.0";
    pyproject = true;
    src = fetchPypi {
      inherit (finalAttrs) version;
      pname = "pysidesix_frameless_window";
      hash = "sha256-4gDkto7bGy4DqgDXbQ6LjR2vbyiaW5H7qXRXi2cArZQ=";
    };
    dependencies = with python3Packages; [ pyside6 ];
    doCheck = false;
    pythonImportsCheck = [ "qframelesswindow" ];
    build-system = with python3Packages; [ setuptools ];
    meta = {
      description = "Frameless window based on PySide6";
      homepage = "https://github.com/zhiyiYo/PyQt-Frameless-Window";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ RoGreat ];
    };
  });
  pyside6-fluent-widgets = python3Packages.buildPythonPackage (finalAttrs: {
    pname = "pyside6-fluent-widgets";
    version = "1.11.2";
    pyproject = true;
    src = fetchPypi {
      inherit (finalAttrs) version;
      pname = "pyside6_fluent_widgets";
      hash = "sha256-z0n/drmyrR3CTwcaGyo/Xwpn1632VZFQcd37c0LK8XU=";
    };
    build-system = with python3Packages; [ setuptools ];
    dependencies = with python3Packages; [
      darkdetect
      pyside6
      pysidesix-frameless-window
    ];
    doCheck = false;
    pythonImportsCheck = [ "qfluentwidgets" ];
    meta = {
      description = "Fluent design widgets library based on PySide6";
      homepage = "https://github.com/zhiyiYo/PyQt-Fluent-Widgets";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ RoGreat ];
    };
  });
  privatebin = python3Packages.buildPythonPackage (finalAttrs: {
    pname = "privatebin";
    version = "0.3.0";
    src = fetchFromGitHub {
      owner = "Ravencentric";
      repo = "privatebin";
      tag = "v${finalAttrs.version}";
      hash = "sha256-jydJJdC7N4fyawTeEUJJgPNbfSJfRU1xYjCRffx842k=";
    };
    pyproject = true;
    build-system = with python3Packages; [ hatchling ];
    dependencies = with python3Packages; [
      base58
      cryptography
      httpx
      msgspec
    ];
    doCheck = false;
    pythonImportsCheck = [ "privatebin" ];
    meta = {
      description = "Python library for interacting with PrivateBin's v2 API";
      homepage = "https://github.com/Ravencentric/privatebin";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ RoGreat ];
    };
  });
in
python3Packages.buildPythonApplication (finalAttrs: {
  inherit src version;
  pname = "crimsondesert-ultimatemodsmanager";
  pyproject = true;

  patches = [
    # https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager/pull/123
    (fetchpatch2 {
      url = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager/compare/6c21db655270db9b002a2f49931972ab3af7e2ad...f9766aa4b5c5d3643288d221ea73065edf82cbe6.diff?full_index=1";
      hash = "sha256-hMUZM0LTUFm4FpMCQ6so5VfeIlCOX5zqSXs43bKKp3k=";
    })
  ];

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
    "tests/test_pamt_cache_honors_cdmods_path.py::test_pamt_cache_uses_parent_when_called_with_vanilla"
    "tests/test_pamt_cache_honors_cdmods_path.py::test_pamt_cache_uses_pointer_for_real_game_dir"
    "tests/test_platform.py::TestOpenPathErrorLogging::test_oserror_logs_path_and_reason"
    "tests/test_transactional_io_absolute_path_guard.py::test_stage_file_rejects_absolute_path"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "cdumm";
      desktopName = "CDUMM";
      icon = "cdumm";
      exec = "cdumm";
      comment = "Crimson Desert Ultimate Mods Manager";
      categories = [ "Game" ];
    })
  ];

  preBuild = ''
    cat >> pyproject.toml << EOL

    [project.scripts]
    cdumm = "cdumm.main:main"
    EOL
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

  preFixup = ''
    makeWrapperArgs+=(
      --suffix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
    )
  '';

  meta = {
    description = "Crimson Desert Ultimate Mods Manager";
    homepage = "https://github.com/RoGreat/CrimsonDesert-UltimateModsManager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cdumm";
    platforms = lib.platforms.linux;
  };
})
