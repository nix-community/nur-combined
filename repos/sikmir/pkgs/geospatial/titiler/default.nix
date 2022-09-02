{ lib, fetchFromGitHub, python3Packages
, rio-tiler, geojson-pydantic, rio-cogeo, starlette-cramjam, cogeo-mosaic }:
let
  pname = "titiler";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "titiler";
    rev = version;
    hash = "sha256-BfN/d2FEFTIuiOHxKltn1SHUdOzDrAkbJcEQANY6UtA=";
  };

  meta = with lib; {
    description = "A modern dynamic tile server built on top of FastAPI and Rasterio/GDAL";
    homepage = "https://developmentseed.org/titiler/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };

  titiler-core = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.core";
    sourceRoot = "${src.name}/src/titiler/core";

    propagatedBuildInputs = with python3Packages; [
      fastapi
      rio-tiler
      geojson-pydantic
    ];
    checkInputs = with python3Packages; [ pytestCheckHook ];
  };

  titiler-mosaic = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.mosaic";
    sourceRoot = "${src.name}/src/titiler/mosaic";

    propagatedBuildInputs = with python3Packages; [
      cogeo-mosaic
      titiler-core
    ];
    checkInputs = with python3Packages; [ pytestCheckHook ];
  };
in
python3Packages.buildPythonPackage {
  inherit pname version src meta;
  sourceRoot = "${src.name}/src/titiler/application";

  propagatedBuildInputs = with python3Packages; [
    python-dotenv
    rio-cogeo
    starlette-cramjam
    titiler-core
    titiler-mosaic
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_mosaic_auth_error"
  ];
}
