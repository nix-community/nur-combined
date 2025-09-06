{
  lib,
  fetchFromGitHub,
  python3Packages,
  cmocean,
}:

python3Packages.buildPythonPackage rec {
  pname = "riverrem";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OpenTopography";
    repo = "RiverREM";
    tag = "v${version}";
    hash = "sha256-pMZahd4CfeGuLz5sd8rT9R0fi2N6hNHe5gBXi1UqYWg=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    cmocean
    gdal
    geopandas
    numpy
    osmnx
    requests
    scipy
    seaborn
    shapely
  ];

  meta = {
    description = "Make river relative elevation models (REM) and REM visualizations from an input digital elevation model (DEM)";
    homepage = "https://github.com/OpenTopography/RiverREM";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # osmnx, cmocean
  };
}
