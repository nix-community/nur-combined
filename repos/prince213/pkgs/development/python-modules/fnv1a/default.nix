{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # nativeCheckInputs
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "fnv1a";
  version = "0.2.0";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "plasticuproject";
    repo = "fnv1a";
    tag = finalAttrs.version;
    hash = "sha256-5XnKkTZ7pJ6bwdzUz46qB6Auk+RVv9Dd2OD63Z1AfJU=";
  };

  build-system = [ setuptools ];

  pythonImportsCheck = [ "fnv1a" ];

  nativeCheckInputs = [ pytestCheckHook ];

  enabledTestPaths = [ "test.py" ];

  meta = {
    description = "64 bit FNV-1a hash module";
    homepage = "https://github.com/plasticuproject/fnv1a";
    downloadPage = "https://github.com/plasticuproject/fnv1a/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
