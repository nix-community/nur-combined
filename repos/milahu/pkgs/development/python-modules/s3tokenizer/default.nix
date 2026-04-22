{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  einops,
  numpy,
  onnx,
  pre-commit,
  torch,
  torchaudio,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "s3tokenizer";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "xingchensong";
    repo = "S3Tokenizer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iwOghxMhIS1b+esweiVNj3a0Y1eIxxATuBSqFzN/t3A=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    einops
    numpy
    onnx
    pre-commit
    torch
    torchaudio
    tqdm
  ];

  pythonImportsCheck = [
    "s3tokenizer"
  ];

  checkPhase = ":";

  meta = {
    description = "Reverse Engineering of Supervised Semantic Speech Tokenizer (S3Tokenizer) proposed in CosyVoice";
    homepage = "https://github.com/xingchensong/S3Tokenizer";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
})
