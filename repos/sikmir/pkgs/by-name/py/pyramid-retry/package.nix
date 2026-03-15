{
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyramid-retry";
  version = "2.1.1";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "pyramid_retry";
    inherit (finalAttrs) version;
    hash = "sha256-uqgnauaLq60J5fL5TvxPdCHzuPtSYVHfUiBS+M0+wMk=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyramid
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    webtest
  ];

  pythonImportsCheck = [ "pyramid_retry" ];

  meta = {
    description = "An execution policy for pyramid that handles retryable errors";
    homepage = "https://github.com/Pylons/pyramid_retry";
    license = lib.licenses.bsd0;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
