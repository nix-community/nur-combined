{
  lib,
  fetchFromGitHub,
  python3Packages,
  rio-stac,
  geojson-pydantic,
  rio-cogeo,
  starlette-cramjam,
  cogeo-mosaic,
}:
let
  pname = "titiler";
  version = "0.22.4";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "titiler";
    tag = version;
    hash = "sha256-VZAKh3y+Uaiha7oI3nWG2gIOXvWm1T1/RHj/kaAx89I=";
  };

  meta = {
    description = "A modern dynamic tile server built on top of FastAPI and Rasterio/GDAL";
    homepage = "https://developmentseed.org/titiler/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    inherit (python3Packages.rio-tiler.meta) broken;
  };

  titiler-core = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.core";
    sourceRoot = "${src.name}/src/titiler/core";
    pyproject = true;

    postPatch = ''
      substituteInPlace pyproject.toml --replace "fastapi-slim>=0.111.0" "fastapi"
    '';

    nativeBuildInputs = with python3Packages; [ pdm-pep517 ];
    dependencies = with python3Packages; [
      fastapi
      jinja2
      rio-tiler
      geojson-pydantic
      simplejson
    ];
    doCheck = false;
    nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  };

  titiler-extensions = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.extensions";
    sourceRoot = "${src.name}/src/titiler/extensions";
    pyproject = true;

    nativeBuildInputs = with python3Packages; [ pdm-pep517 ];
    dependencies = with python3Packages; [
      rio-cogeo
      rio-stac
      titiler-core
    ];
    doCheck = false;
    nativeCheckInputs = with python3Packages; [
      pytestCheckHook
      jsonschema
    ];
    disabledTests = [ "test_stacExtension" ];
  };

  titiler-mosaic = python3Packages.buildPythonPackage {
    inherit version src meta;
    pname = "${pname}.mosaic";
    sourceRoot = "${src.name}/src/titiler/mosaic";
    pyproject = true;

    nativeBuildInputs = with python3Packages; [ pdm-pep517 ];
    dependencies = with python3Packages; [
      cogeo-mosaic
      titiler-core
    ];
    doCheck = false;
    nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  };
in
python3Packages.buildPythonPackage {
  inherit
    pname
    version
    src
    meta
    ;
  sourceRoot = "${src.name}/src/titiler/application";
  pyproject = true;

  nativeBuildInputs = with python3Packages; [ pdm-pep517 ];
  dependencies = with python3Packages; [
    python-dotenv
    rio-cogeo
    starlette-cramjam
    titiler-core
    titiler-extensions
    titiler-mosaic
  ];

  doCheck = false;
  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [ "test_mosaic_auth_error" ];
}
