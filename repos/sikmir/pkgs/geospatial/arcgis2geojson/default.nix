{ lib, python3Packages, fetchFromGitHub, poetry }:

python3Packages.buildPythonApplication rec {
  pname = "arcgis2geojson";
  version = "2.0.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "chris48s";
    repo = "arcgis2geojson";
    rev = version;
    hash = "sha256-NA1yNNZbx7ATFhgo2Be38liHQ5DWr66FDd24FaYur3M=";
  };

  nativeBuildInputs = [ poetry ];

  meta = with lib; {
    description = "A Python library for converting ArcGIS JSON to GeoJSON";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
