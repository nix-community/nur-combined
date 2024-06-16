{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "osm2geojson";
  version = "0.1.33";

  src = fetchFromGitHub {
    owner = "aspectumapp";
    repo = "osm2geojson";
    rev = "068b83afe19cff1ae15b9efc2a9ff5a9be8928e7";
    hash = "sha256-9+xB/fd97HtnzdkJ2BawVW9AqDyArWUv6H1SZ7a8gkw=";
    fetchSubmodules = true;
  };

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
  };
}
