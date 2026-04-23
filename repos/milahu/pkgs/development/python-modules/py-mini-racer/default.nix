{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-mini-racer";
  version = "0.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sqreen";
    repo = "PyMiniRacer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r6ghH1uPbnM4cruxgcOkHv3HsC29p3fILtH3Mzpy8yQ=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "py_mini_racer"
  ];

  meta = {
    description = "PyMiniRacer is a V8 bridge in Python";
    homepage = "https://github.com/sqreen/PyMiniRacer";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
  };
})
