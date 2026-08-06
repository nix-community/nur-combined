{
  buildPythonPackage,
  fetchPypi,
  lib,
  pyside6,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysidesix-frameless-window";
  version = "0.8.2";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) version;
    pname = "pysidesix_frameless_window";
    hash = "sha256-PLv4r9OQ2p6kP8l9SjpCxTaq8I0kSnIrEU7/AFS3/ww=";
  };

  build-system = [ setuptools ];

  dependencies = [ pyside6 ];

  doCheck = false;

  pythonImportsCheck = [ "qframelesswindow" ];

  meta = {
    description = "Frameless window based on PySide6";
    homepage = "https://github.com/zhiyiYo/PyQt-Frameless-Window";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
