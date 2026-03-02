{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "osmviz";
  version = "4.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hugovk";
    repo = "osmviz";
    tag = finalAttrs.version;
    hash = "sha256-Kvdbw5RMBVHt6sM8oGkMM28SPIIegNpJ/53pSpOx36I=";
  };

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
    coverage
    pillow
    pygame
  ];

  pytestFlagsArray = [
    "-W"
    "ignore::DeprecationWarning"
  ];

  disabledTests = [
    "test_pil"
    "test_retrieve_tile_image"
    "test_create_osm_image"
    "test_sim"
    "test_sim_one"
  ];

  pythonImportsCheck = [ "osmviz" ];

  meta = {
    description = "An OpenStreetMap Visualization Toolkit for Python";
    homepage = "https://github.com/hugovk/osmviz";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
