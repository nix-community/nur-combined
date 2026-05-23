{
  fetchFromGitHub,
  fetchPypi,
  lib,
  python3Packages,
  rustPlatform,
}:
let
  version = "0-unstable-2026-05-22";
  src = fetchFromGitHub {
    owner = "RoGreat";
    repo = "CrimsonDesert-UltimateModsManager";
    rev = "36bb623559d3b56befe9f52495bd70b72dc87fb8";
    hash = "sha256-4/homaH0v19OeMXnVIF41bU5wNPnw2Q2/O0s9Ej2O5o=";
  };
  cdumm-native = python3Packages.buildPythonApplication (finalAttrs: {
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

  pysidesix-frameless-window = python3Packages.buildPythonApplication (finalAttrs: {
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
  pyside6-fluent-widgets = python3Packages.buildPythonApplication (finalAttrs: {
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
  privatebin = python3Packages.buildPythonApplication (finalAttrs: {
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
    pyside6
    pyside6-fluent-widgets
  ];

  postInstall = ''
    cp -a src/cdumm/translations $out/${python3Packages.python.sitePackages}/cdumm/translations
  '';

  doCheck = false;

  meta = {
    description = "Crimson Desert Ultimate Mods Manager";
    homepage = "https://github.com/RoGreat/CrimsonDesert-UltimateModsManager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cdumm";
    platforms = lib.platforms.linux;
  };
})
