{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "tilematrix";
  version = "2024.11.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ungarj";
    repo = "tilematrix";
    tag = finalAttrs.version;
    hash = "sha256-ZhSdLcbvvW0YS8rCIFbuBmyQvtfCP9NDSuF1vWiCVf0=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    affine
    click
    geojson
    rasterio
    shapely
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
  ];

  disabledTests = [
    "test_bbox"
    "test_tile"
  ];

  meta = {
    description = "Helps handling tile pyramids";
    homepage = "https://github.com/ungarj/tilematrix";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
