{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "arcgis2geojson";
  version = "3.0.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "chris48s";
    repo = "arcgis2geojson";
    rev = version;
    hash = "sha256-6lXfQoazBABryyuch1PJF/7yPq7cOBuvGWCqBUVPdts=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "poetry.masonry" "poetry.core.masonry"
  '';

  nativeBuildInputs = with python3Packages; [ poetry-core ];

  meta = with lib; {
    description = "A Python library for converting ArcGIS JSON to GeoJSON";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
