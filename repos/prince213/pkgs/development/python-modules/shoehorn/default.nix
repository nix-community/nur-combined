{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # nativeCheckInputs
  pytestCheckHook,
  testfixtures,
}:

buildPythonPackage (finalAttrs: {
  pname = "shoehorn";
  version = "0.2.3";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "cjw296";
    repo = "shoehorn";
    tag = finalAttrs.version;
    hash = "sha256-agJT2V3Qq6Cky5ma1VsW+6sWE+PGpVTg/P+LrIktwXY=";
  };

  build-system = [ setuptools ];

  pythonImportsCheck = [ "shoehorn" ];

  nativeCheckInputs = [
    pytestCheckHook
    testfixtures
  ];

  meta = {
    description = "Shoehorn structured logs into or out of standard library logging";
    homepage = "https://github.com/cjw296/shoehorn";
    downloadPage = "https://github.com/cjw296/shoehorn/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
