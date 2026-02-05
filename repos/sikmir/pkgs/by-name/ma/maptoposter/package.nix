{
  lib,
  fetchFromGitHub,
  python3Packages,
  lat-lon-parser,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "maptoposter";
  version = "0.3.0-unstable-2026-01-30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "originalankur";
    repo = "maptoposter";
    rev = "fffad0c276f5bbab1e6f242144126c574f72705a";
    hash = "sha256-deHv04POhh3GOa3EESSvF2YqxXiWR3ILivgh1aGXlZk=";
    leaveDotGit = true;
  };

  build-system = with python3Packages; [ setuptools ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    certifi
    charset-normalizer
    contourpy
    cycler
    fonttools
    geographiclib
    geopandas
    geopy
    idna
    kiwisolver
    lat-lon-parser
    matplotlib
    networkx
    numpy
    osmnx
    packaging
    pandas
    pillow
    pyogrio
    pyparsing
    pyproj
    python-dateutil
    pytz
    requests
    scipy
    shapely
    tqdm
    tzdata
    urllib3
  ];

  meta = {
    description = "City Map Poster Generator";
    homepage = "https://github.com/originalankur/maptoposter";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
