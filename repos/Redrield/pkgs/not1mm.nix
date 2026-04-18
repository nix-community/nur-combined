{ lib, python3Packages, fetchPypi, qt6Packages, notctyparser, appdata, adif-io }:
python3Packages.buildPythonApplication rec {
  pname = "not1mm";
  version = "26.4.14";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eIcasJM+6ifVIsfReu0ZZTI+OdGrpb5eNa/zfeHTyDM=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  buildInputs = [
    qt6Packages.qtwayland
  ];

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
  ];

  dependencies = with python3Packages; [ 
    pyqt6 
    requests
    dicttoxml
    xmltodict
    pyserial
    sounddevice
    soundfile
    numpy
    rapidfuzz
    notctyparser
    appdata
    adif-io
  ];

  preBuild = ''
    substituteInPlace pyproject.toml --replace-fail "license = \"GPL-3.0-or-later\"" "license.file = \"LICENSE\""
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';
}
