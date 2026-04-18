{ python3Packages, lib, fetchPypi, qt6Packages }:
python3Packages.buildPythonApplication rec {

  pname = "winkeyerserial";
  version = "25.9.13.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;

    hash = "sha256-TcCmufdlKPfDz87lQRsdx20j/zIUF8+jx5KzUiMfOF8=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ pyqt6 pyserial ];

  buildInputs = [
    qt6Packages.qtwayland
  ];

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
  ];

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';
}
