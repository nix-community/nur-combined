{
  lib,
  fetchFromGitHub,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "segmentation-models-pytorch";
  version = "0.5.0";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "qubvel-org";
    repo = "segmentation_models.pytorch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QtrmMbVcFHftV69stJHk0+3n1o0inlO22xHs/smLlGg=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    numpy
    pillow
    safetensors
    timm
    torch
    torchvision
    tqdm
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    gitpython
    writableTmpDirAsHomeHook
  ];

  doCheck = false;

  meta = {
    description = "Image segmentation models with pre-trained backbones";
    homepage = "https://github.com/qubvel-org/segmentation_models.pytorch";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
