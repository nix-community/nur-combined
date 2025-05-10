{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "geojson-pydantic";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "geojson-pydantic";
    tag = version;
    hash = "sha256-SOo4Hs1WMUerMLMgjzUVuDkUXCuiStJ4P9iMSpUF8Uw=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    pydantic
    shapely
  ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Pydantic data models for the GeoJSON spec";
    homepage = "https://github.com/developmentseed/geojson-pydantic";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
