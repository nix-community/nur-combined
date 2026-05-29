{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage (final: {
  pname = "sageattention";
  version = "2.2.0-unstable-2025-08-05";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "thu-ml";
    repo = "SageAttention";
    rev = "2bec28a19edaba8cddfba60c0ab87a0f7f9b58f6";
    hash = "sha256-IYk4ZQ4z/M2MOA4BRUnTfai+DS6kYt0VNI0z1tJfKxY=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3Packages; [
    torch
    triton
  ];

  pythonImportsCheck = [
    "sageattention"
  ];

  meta = {
    description = "Fast quantized attention for all models (version 1 that works with AMD GPUs)";
    homepage = "https://github.com/thu-ml/SageAttention";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
