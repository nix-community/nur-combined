{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "overpassforge";
  version = "0.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Krafpy";
    repo = "Overpass-Forge";
    tag = version;
    hash = "sha256-HtP1aSIf6iOyZDhDF/kDps1hMgKHKOAlPjYwOQSeXjE=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "overpassforge" ];

  meta = {
    description = "A library for generating OpenStreetMap's Overpass QL queries from Python objects";
    homepage = "https://github.com/Krafpy/Overpass-Forge";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
