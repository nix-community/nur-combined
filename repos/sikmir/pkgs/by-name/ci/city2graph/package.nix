{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  overturemaps,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "city2graph";
  version = "0.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "c2g-dev";
    repo = "city2graph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dqdupUF7mS49J8BNnh9VVdsNmPIqHHUzi8DF3zaLMZs=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    geopy
    networkx
    osmnx
    shapely
    geopandas
    libpysal
    momepy
    overturemaps
    rustworkx
    torch
    torch-geometric
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
    broken = stdenv.isDarwin;
  };
})
