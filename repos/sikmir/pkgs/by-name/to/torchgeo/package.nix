{
  lib,
  fetchFromGitHub,
  python3Packages,
  lightly,
  segmentation-models-pytorch,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "torchgeo";
  version = "0.10.1";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "torchgeo";
    repo = "torchgeo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CDUCaccz2WlKqoawlFAkjzr3Jp74iQB68mnqLY/SR4E=";
  };

  build-system = with python3Packages; [ uv-build ];

  dependencies =
    with python3Packages;
    [
      einops
      geopandas
      jsonargparse
      kornia
      lightly
      lightning
      matplotlib
      numpy
      pandas
      pillow
      pyogrio
      pyproj
      rasterio
      requests
      segmentation-models-pytorch
      shapely
      timm
      torch
      torchmetrics
      tqdm
      typing-extensions
    ]
    ++ jsonargparse.optional-dependencies.jsonnet
    ++ jsonargparse.optional-dependencies.signatures;

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-socket
    writableTmpDirAsHomeHook
  ];

  doCheck = false;

  meta = {
    description = "TorchGeo: datasets, samplers, transforms, and pre-trained models for geospatial data";
    homepage = "https://github.com/torchgeo/torchgeo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
