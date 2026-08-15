{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "lightly";
  version = "1.5.26-unstable-2026-08-14";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "lightly-ai";
    repo = "lightly";
    rev = "483f80923c6ffd47c7f0fedab98e3d46d873a27b";
    hash = "sha256-Epama3wvNBhmLJSfa+AxzAh0fYRb1cQWgcK43+apvUQ=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    hydra-core
    numpy
    tqdm
    torch
    torchvision
    pytorch-lightning
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-mock
    scikit-learn
  ];

  disabledTests = [
    "test_loss_dcl"
  ];

  meta = {
    description = "Deep learning package for self-supervised learning";
    homepage = "https://github.com/lightly-ai/lightly";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
