{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "overpassforge";
  version = "0.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Krafpy";
    repo = "Overpass-Forge";
    tag = finalAttrs.version;
    hash = "sha256-UH8fZl9qXsJHM1/kDL1Z7ZynALbK8Wiex/e3+KAWH7A=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "overpassforge" ];

  meta = {
    description = "A library for generating OpenStreetMap's Overpass QL queries from Python objects";
    homepage = "https://github.com/Krafpy/Overpass-Forge";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
