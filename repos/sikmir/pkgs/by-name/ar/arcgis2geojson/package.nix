{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "arcgis2geojson";
  version = "3.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chris48s";
    repo = "arcgis2geojson";
    tag = finalAttrs.version;
    hash = "sha256-q02LBxncxfbQM3bVDYWBOw8EuysyFv9lmJ0VBtq+vl0=";
  };

  build-system = with python3Packages; [ poetry-core ];

  meta = {
    description = "A Python library for converting ArcGIS JSON to GeoJSON";
    homepage = "https://github.com/chris48s/arcgis2geojson";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
