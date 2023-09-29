{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "overpassforge";
  version = "0.4.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Krafpy";
    repo = "Overpass-Forge";
    rev = version;
    hash = "sha256-HtP1aSIf6iOyZDhDF/kDps1hMgKHKOAlPjYwOQSeXjE=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "overpassforge" ];

  meta = with lib; {
    description = "A library for generating OpenStreetMap's Overpass QL queries from Python objects";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
