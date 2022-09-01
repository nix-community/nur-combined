{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "osm2geojson";
  version = "0.1.33";

  src = fetchFromGitHub {
    owner = "aspectumapp";
    repo = pname;
    rev = "068b83afe19cff1ae15b9efc2a9ff5a9be8928e7";
    hash = "sha256-9+xB/fd97HtnzdkJ2BawVW9AqDyArWUv6H1SZ7a8gkw=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = with python3Packages; [
    shapely
    requests
  ];

  doCheck = false;

  meta = with lib; {
    description = "Convert OSM and Overpass JSON to GeoJSON";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
