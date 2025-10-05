{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  overturemaps,
}:

python3Packages.buildPythonPackage rec {
  pname = "city2graph";
  version = "0.1.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "c2g-dev";
    repo = "city2graph";
    tag = "v${version}";
    hash = "sha256-wjce9I1HBQklQUwVObhlPmXGOZeX1Jm+kGKC9dm4oEw=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    networkx
    osmnx
    shapely
    geopandas
    libpysal
    momepy
    overturemaps
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
  ];

  meta = {
    description = "GeoAI with Graph Neural Networks (GNNs) and Spatial Network Analysis";
    homepage = "https://github.com/c2g-dev/city2graph";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
