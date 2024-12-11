{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  numpy,
  torch,
  torch-complex,
}:
buildPythonPackage rec {
  inherit (sources.pytorch-wpe) pname version src;

  propagatedBuildInputs = [
    numpy
    torch
    torch-complex
  ];

  pythonImportsCheck = [ "pytorch_wpe" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "WPE implementation using PyTorch";
    homepage = "https://github.com/nttcslab-sp/dnn_wpe";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}
