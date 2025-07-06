{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "osm2geojson";
  version = "0.2.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "aspectumapp";
    repo = "osm2geojson";
    rev = "056765567079ee1fff01aded3b66232b436ba1d2";
    hash = "sha256-Uu4+L5FPhyx5pgmkzly2jtuA4aSkkg9bwcbaP7F25Y8=";
    fetchSubmodules = true;
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    shapely
    requests
  ];

  doCheck = false;

  meta = {
    description = "Convert OSM and Overpass JSON to GeoJSON";
    homepage = "https://github.com/aspectumapp/osm2geojson";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "osm2geojson";
  };
}
