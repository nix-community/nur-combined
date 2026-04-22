{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cython,
  setuptools,
  wheel,
  numpy,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "diffq";
  version = "0.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "diffq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dW+l3T61v1QLKQpAsXi5zX5OhVHsg18ZhRfxPoTmhx4=";
  };

  build-system = [
    cython
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "diffq"
  ];

  dependencies = [
    numpy
    torch
  ];

  meta = {
    description = "DiffQ performs differentiable quantization using pseudo quantization noise. It can automatically tune the number of bits used per weight or group of weights, in order to achieve a given trade-off between model size and accuracy";
    homepage = "https://github.com/facebookresearch/diffq";
    changelog = "https://github.com/facebookresearch/diffq/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.cc-by-nc-40;
    maintainers = with lib.maintainers; [ ];
  };
})
