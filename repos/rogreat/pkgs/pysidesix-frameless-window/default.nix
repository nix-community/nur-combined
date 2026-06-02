{
  buildPythonPackage,
  fetchPypi,
  lib,
  pyside6,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysidesix-frameless-window";
  version = "0.8.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) version;
    pname = "pysidesix_frameless_window";
    hash = "sha256-le76ZKvayp1zC8CX/TnizQfTRDpHoWRcyTagB2mW180=";
  };

  dependencies = [ pyside6 ];

  doCheck = false;

  pythonImportsCheck = [ "qframelesswindow" ];

  build-system = [ setuptools ];

  meta = {
    description = "Frameless window based on PySide6";
    homepage = "https://github.com/zhiyiYo/PyQt-Frameless-Window";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ RoGreat ];
  };
})
