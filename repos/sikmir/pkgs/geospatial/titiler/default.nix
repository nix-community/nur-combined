{ lib, fetchFromGitHub, python3Packages
, rio-stac, rio-tiler, geojson-pydantic, rio-cogeo, starlette-cramjam, cogeo-mosaic }:
let
  pname = "titiler";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "titiler";
    rev = version;
    hash = "sha256-AdG2fZTvmgnTccLtHj4C3SzdqJ10icr3q3SNmRCtq0E=";
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
      simplejson
    ];
    nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  };

  titiler-extensions = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.extensions";
    sourceRoot = "${src.name}/src/titiler/extensions";

    propagatedBuildInputs = with python3Packages; [
      rio-cogeo
      rio-stac
      titiler-core
    ];
    nativeCheckInputs = with python3Packages; [ pytestCheckHook jsonschema ];
    disabledTests = [ "test_stacExtension" ];
  };

  titiler-mosaic = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.mosaic";
    sourceRoot = "${src.name}/src/titiler/mosaic";

    propagatedBuildInputs = with python3Packages; [
      cogeo-mosaic
      titiler-core
    ];
    nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
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
    titiler-extensions
    titiler-mosaic
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_mosaic_auth_error"
  ];
}
