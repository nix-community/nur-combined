{
  lib,
  fetchFromGitHub,
  python3Packages,
  inequality,
}:

python3Packages.buildPythonPackage rec {
  pname = "momepy";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pysal";
    repo = "momepy";
    rev = "v${version}";
    hash = "sha256-HVp2a0z+5fbfkNSxnTfZPCgG2SJMlKX/zso14M18mCk=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  propagatedBuildInputs = with python3Packages; [
    geopandas
    libpysal
    networkx
    packaging
    pandas
    shapely
    tqdm
  ];

  nativeCheckInputs = with python3Packages; [
    inequality
    mapclassify
    pytestCheckHook
  ];

  pythonImportsCheck = [ "momepy" ];

  meta = {
    description = "Urban Morphology Measuring Toolkit";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
