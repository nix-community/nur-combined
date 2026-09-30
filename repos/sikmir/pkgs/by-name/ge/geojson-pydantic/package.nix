{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "geojson-pydantic";
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "geojson-pydantic";
    tag = finalAttrs.version;
    hash = "sha256-XNSD54gNOVY7aXuw1cO0FGG3zTtecgZaWxC9KndyV9k=";
  };

  build-system = with python3Packages; [ hatchling ];

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
})
