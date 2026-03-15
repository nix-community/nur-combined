{
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyramid-debugtoolbar";
  version = "4.12.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "pyramid_debugtoolbar";
    inherit (finalAttrs) version;
    hash = "sha256-ceiI00nIX8yhKz5txMeujj8CodWswFFU/Zuox/ZhtD0=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyramid
    pyramid-mako
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    sqlalchemy
    webtest
  ];

  pythonImportsCheck = [ "pyramid_debugtoolbar" ];

  disabledTests = [ "test_panel" ];

  meta = {
    description = "Pyramid debug toolbar";
    homepage = "https://github.com/Pylons/pyramid_debugtoolbar";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
