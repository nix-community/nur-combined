{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  # Dependencies
  numpy,
  torch,
  torch-complex,
}:
buildPythonPackage rec {
  inherit (sources.pytorch-wpe) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    numpy
    torch
    torch-complex
  ];

  pythonImportsCheck = [ "pytorch_wpe" ];

  meta = {
    changelog = "https://github.com/nttcslab-sp/dnn_wpe/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "WPE implementation using PyTorch";
    homepage = "https://github.com/nttcslab-sp/dnn_wpe";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}
