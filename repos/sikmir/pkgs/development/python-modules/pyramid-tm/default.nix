{
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyramid-tm";
  version = "2.6";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "pyramid_tm";
    inherit (finalAttrs) version;
    hash = "sha256-gUjSGRKFKAyaDCPm3xAYs1FLTO8CEVuHLdA1Ck14cJw=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyramid
    transaction
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
    webtest
  ];

  pythonImportsCheck = [ "pyramid_tm" ];

  meta = {
    description = "A package which allows Pyramid requests to join the active transaction";
    homepage = "https://github.com/Pylons/pyramid_tm";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
