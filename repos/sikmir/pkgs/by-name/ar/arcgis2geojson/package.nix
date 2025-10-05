{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "arcgis2geojson";
  version = "3.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chris48s";
    repo = "arcgis2geojson";
    tag = version;
    hash = "sha256-w3teY/CLNGF3h+8R6KoYCvjat8q6ellet1awEPOXpac=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry.masonry" "poetry.core.masonry"
  '';

  build-system = with python3Packages; [ poetry-core ];

  meta = {
    description = "A Python library for converting ArcGIS JSON to GeoJSON";
    homepage = "https://github.com/chris48s/arcgis2geojson";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
}
