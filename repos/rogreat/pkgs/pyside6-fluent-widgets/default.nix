{
  buildPythonPackage,
  darkdetect,
  fetchPypi,
  lib,
  pyside6,
  pysidesix-frameless-window,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyside6-fluent-widgets";
  version = "1.11.2";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) version;
    pname = "pyside6_fluent_widgets";
    hash = "sha256-z0n/drmyrR3CTwcaGyo/Xwpn1632VZFQcd37c0LK8XU=";
  };

  build-system = [ setuptools ];

  dependencies = [
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
})
