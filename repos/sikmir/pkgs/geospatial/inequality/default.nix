{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "inequality";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pysal";
    repo = "inequality";
    rev = "v${version}";
    hash = "sha256-dy1/KXnmIh5LnTxuyYfIvtt1p2CIpNQ970o5pTg6diQ=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  propagatedBuildInputs = with python3Packages; [
    libpysal
    numpy
    scipy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "inequality" ];

  meta = {
    description = "Spatial inequality analysis";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
