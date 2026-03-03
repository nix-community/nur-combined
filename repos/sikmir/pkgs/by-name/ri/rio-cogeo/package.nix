{
  lib,
  fetchFromGitHub,
  python3Packages,
  cogdumper,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "rio-cogeo";
  version = "7.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-cogeo";
    tag = finalAttrs.version;
    hash = "sha256-5sEvkIkJk2Z+N8M1OvAHa3c7VA/BJviMg+DN1j2/c1o=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    click
    rasterio
    numpy
    morecantile
    pydantic
  ];

  pythonRelaxDeps = [ "morecantile" ];

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    cogdumper
  ];

  meta = {
    description = "Cloud Optimized GeoTIFF creation and validation plugin for rasterio";
    homepage = "https://github.com/cogeotiff/rio-cogeo";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
